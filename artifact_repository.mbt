// ==================================================================
// Durable artifact repository over an abstract byte store.
//
// The compiled-module and schema-registry binary formats produce
// self-checking byte blobs; this file gives them a storage
// policy that can outlive a process.  MoonBit core (as used by
// this project) exposes no importable filesystem package, so the
// repository is written against an abstract byte-store interface
// (`ArtifactByteStore`: read/write/remove/list callbacks over
// string keys).  An in-memory implementation is provided; a host
// embedding can back the same interface with real files.  The
// repository protocol itself — content addressing, verified
// two-phase writes, commit manifests, an index, and recovery by
// rescanning commit manifests — is fully implemented and
// checked here, and depends only on the store honouring "a
// completed write is durable".
//
// Layout under the repository prefix:
//   <prefix>/index.bin                  CHARTIDX envelope
//   <prefix>/blobs/<digest>.bin        artifact bytes
//   <prefix>/blobs/<digest>.bin.commit CHARTCOM manifest
// A blob becomes visible only when its commit manifest exists;
// the index is a cache of the manifests and can always be
// rebuilt by `artifact_repository_recover`.
// ==================================================================

///|
/// Abstract byte store: the storage backend the repository
/// protocol runs over.  `write` reports whether the bytes were
/// durably accepted; `list` enumerates all keys.
pub struct ArtifactByteStore {
  read : (String) -> Array[Int32]?
  write : (String, Array[Int32]) -> Bool
  remove : (String) -> Bool
  list : () -> Array[String]
}

///|
pub fn artifact_byte_store_new(
  read~ : (String) -> Array[Int32]?,
  write~ : (String, Array[Int32]) -> Bool,
  remove~ : (String) -> Bool,
  list~ : () -> Array[String],
) -> ArtifactByteStore {
  ArtifactByteStore::{ read, write, remove, list, }
}

///|
/// In-memory byte store, for tests and same-process use.  Bytes
/// are copied on write and on read, so callers cannot mutate
/// stored content behind the repository's back.
pub fn artifact_memory_byte_store_new() -> ArtifactByteStore {
  let entries : Array[(String, Array[Int32])] = []
  let copy = (bytes : Array[Int32]) => {
    let out : Array[Int32] = []
    for i in 0..<bytes.length() {
      out.push(bytes[i])
    }
    out
  }
  artifact_byte_store_new(
    read=key => {
      for i in 0..<entries.length() {
        if entries[i].0 == key {
          return Some(copy(entries[i].1))
        }
      }
      None
    },
    write=(key, bytes) => {
      for i in 0..<entries.length() {
        if entries[i].0 == key {
          entries[i] = (key, copy(bytes))
          return true
        }
      }
      entries.push((key, copy(bytes)))
      true
    },
    remove=key => {
      for i in 0..<entries.length() {
        if entries[i].0 == key {
          ignore(entries.remove(i))
          return true
        }
      }
      false
    },
    list=() => {
      let out : Array[String] = []
      for i in 0..<entries.length() {
        out.push(entries[i].0)
      }
      out
    },
  )
}

///|
/// One committed artifact: its logical identity (`kind`, `name`)
/// and the content-addressed blob holding its bytes, with the
/// length and dual checksums recorded in the commit manifest.
pub struct ArtifactRecord {
  kind : String
  name : String
  blob_key : String
  byte_length : Int32
  hash_a : Int32
  hash_b : Int32
  format_version : Int32
} derive(Debug, Eq)

///|
pub extend ArtifactRecord with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ArtifactRecord with Eq::{not_equal, equal}

///|
pub struct ArtifactRepository {
  store : ArtifactByteStore
  prefix : String
  mut puts : Int32
  mut recoveries : Int32
}

///|
pub fn artifact_repository_new(
  store : ArtifactByteStore,
  prefix~ : String = "artifacts",
) -> ArtifactRepository {
  ArtifactRepository::{ store, prefix, puts: 0, recoveries: 0, }
}

///|
pub struct ArtifactRepositoryStats {
  records : Int32
  total_bytes : Int32
  puts : Int32
  recoveries : Int32
} derive(Debug, Eq)

///|
pub extend ArtifactRepositoryStats with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ArtifactRepositoryStats with Eq::{not_equal, equal}

// ------------------------------------------------------------------
// Digests and small helpers
// ------------------------------------------------------------------

///|
fn artifact_hash_pair(bytes : Array[Int32]) -> (Int32, Int32) {
  let mut a = 17
  let mut b = 29
  for i in 0..<bytes.length() {
    let byte = bytes[i] & 255
    a = (a * 31 + byte + 1) % 1000000007
    b = (b * 131 + byte + 7) % 998244353
  }
  (a, b)
}

///|
fn artifact_blob_digest(bytes : Array[Int32]) -> String {
  let (a, b) = artifact_hash_pair(bytes)
  "\{bytes.length()}-\{a}-\{b}"
}

///|
fn artifact_name_ok(name : String) -> Bool {
  if name.length() == 0 {
    return false
  }
  for c in name {
    if c == '/' || c == '\\' {
      return false
    }
  }
  true
}

///|
fn artifact_index_key(repo : ArtifactRepository) -> String {
  repo.prefix + "/index.bin"
}

///|
fn artifact_blob_key(repo : ArtifactRepository, digest : String) -> String {
  repo.prefix + "/blobs/" + digest + ".bin"
}

///|
/// Two-phase verified write: stage at `<key>.tmp`, read back and
/// compare, then write the final key and verify again.  A crash
/// between phases leaves at most a harmless staging key.
fn artifact_store_write_verified(
  store : ArtifactByteStore,
  key : String,
  bytes : Array[Int32],
) -> Bool {
  let staging = key + ".tmp"
  if !(store.write)(staging, bytes) {
    return false
  }
  match (store.read)(staging) {
    Some(back) => if back != bytes { return false }
    None => return false
  }
  if !(store.write)(key, bytes) {
    return false
  }
  match (store.read)(key) {
    Some(back) => if back != bytes { return false }
    None => return false
  }
  ignore((store.remove)(staging))
  true
}

// ------------------------------------------------------------------
// Envelopes (CHARTCOM manifests and the CHARTIDX index)
// ------------------------------------------------------------------

///|
fn artifact_envelope(
  magic : Array[Int32],
  payload : Array[Int32],
) -> Array[Int32] {
  let writer = module_bin_writer_new()
  for i in 0..<magic.length() {
    bw_u8(writer, magic[i])
  }
  bw_u8(writer, 1)
  bw_u8(writer, 0)
  bw_u8(writer, 0)
  bw_u8(writer, 0)
  bw_i32(writer, payload.length())
  bw_i32(writer, module_binary_checksum(payload))
  for i in 0..<payload.length() {
    bw_u8(writer, payload[i])
  }
  writer.bytes
}

///|
fn artifact_envelope_payload(
  magic : Array[Int32],
  bytes : Array[Int32],
) -> Array[Int32]? {
  if bytes.length() < 20 {
    return None
  }
  for i in 0..<bytes.length() {
    if bytes[i] < 0 || bytes[i] > 255 {
      return None
    }
  }
  for i in 0..<8 {
    if bytes[i] != magic[i] {
      return None
    }
  }
  if module_binary_u16_at(bytes, 8) != 1 || module_binary_u16_at(bytes, 10) != 0 {
    return None
  }
  let payload_length = module_binary_i32_at(bytes, 12)
  if payload_length < 0 || bytes.length() != 20 + payload_length {
    return None
  }
  let payload : Array[Int32] = []
  for i in 0..<payload_length {
    payload.push(bytes[20 + i])
  }
  if module_binary_checksum(payload) != module_binary_i32_at(bytes, 16) {
    return None
  }
  Some(payload)
}

///|
fn bw_artifact_record(w : ModuleBinWriter, record : ArtifactRecord) -> Unit {
  bw_string(w, record.kind)
  bw_string(w, record.name)
  bw_string(w, record.blob_key)
  bw_i32(w, record.byte_length)
  bw_i32(w, record.hash_a)
  bw_i32(w, record.hash_b)
  bw_i32(w, record.format_version)
}

///|
fn br_artifact_record(r : ModuleBinReader) -> ArtifactRecord? {
  let kind = match br_string(r) {
    Some(v) => v
    None => return None
  }
  let name = match br_string(r) {
    Some(v) => v
    None => return None
  }
  let blob_key = match br_string(r) {
    Some(v) => v
    None => return None
  }
  let byte_length = br_i32(r)
  let hash_a = br_i32(r)
  let hash_b = br_i32(r)
  let format_version = br_i32(r)
  if !br_require_ok(r) || byte_length < 0 {
    return None
  }
  Some(ArtifactRecord::{
    kind,
    name,
    blob_key,
    byte_length,
    hash_a,
    hash_b,
    format_version,
  })
}

///|
fn artifact_manifest_bytes(record : ArtifactRecord) -> Array[Int32] {
  let writer = module_bin_writer_new_versioned(3)
  bw_artifact_record(writer, record)
  artifact_envelope([67, 72, 65, 82, 84, 67, 79, 77], writer.bytes)
}

///|
fn artifact_manifest_parse(bytes : Array[Int32]) -> ArtifactRecord? {
  let payload = match
    artifact_envelope_payload([67, 72, 65, 82, 84, 67, 79, 77], bytes) {
    Some(v) => v
    None => return None
  }
  let reader = module_bin_reader_new_versioned(payload, 3)
  let record = br_artifact_record(reader)
  if reader.pos != payload.length() || reader.status != ModuleBinaryOk {
    return None
  }
  record
}

///|
fn artifact_index_bytes(records : Array[ArtifactRecord]) -> Array[Int32] {
  let writer = module_bin_writer_new_versioned(3)
  bw_i32(writer, records.length())
  for i in 0..<records.length() {
    bw_artifact_record(writer, records[i])
  }
  artifact_envelope([67, 72, 65, 82, 84, 73, 68, 88], writer.bytes)
}

///|
fn artifact_index_parse(bytes : Array[Int32]) -> Array[ArtifactRecord]? {
  let payload = match
    artifact_envelope_payload([67, 72, 65, 82, 84, 73, 68, 88], bytes) {
    Some(v) => v
    None => return None
  }
  let reader = module_bin_reader_new_versioned(payload, 3)
  let count = br_count(reader)
  if !br_require_ok(reader) {
    return None
  }
  let records : Array[ArtifactRecord] = []
  for _i in 0..<count {
    match br_artifact_record(reader) {
      Some(v) => records.push(v)
      None => return None
    }
  }
  if reader.pos != payload.length() || reader.status != ModuleBinaryOk {
    return None
  }
  Some(records)
}

// ------------------------------------------------------------------
// Index handling
// ------------------------------------------------------------------

///|
/// Load the index; a missing index is the empty repository, a
/// corrupt one is reported as `None` (run recovery).
fn artifact_repository_load_index(
  repo : ArtifactRepository,
) -> Array[ArtifactRecord]? {
  match (repo.store.read)(artifact_index_key(repo)) {
    Some(bytes) => artifact_index_parse(bytes)
    None => Some([])
  }
}

///|
fn artifact_repository_save_index(
  repo : ArtifactRepository,
  records : Array[ArtifactRecord],
) -> Bool {
  artifact_store_write_verified(
    repo.store,
    artifact_index_key(repo),
    artifact_index_bytes(records),
  )
}

///|
fn artifact_records_find(
  records : Array[ArtifactRecord],
  kind : String,
  name : String,
) -> ArtifactRecord? {
  for i in 0..<records.length() {
    if records[i].kind == kind && records[i].name == name {
      return Some(records[i])
    }
  }
  None
}

///|
fn artifact_record_matches_bytes(
  record : ArtifactRecord,
  bytes : Array[Int32],
) -> Bool {
  let (a, b) = artifact_hash_pair(bytes)
  record.byte_length == bytes.length() &&
  record.hash_a == a &&
  record.hash_b == b
}

// ------------------------------------------------------------------
// Repository operations
// ------------------------------------------------------------------

///|
/// Commit `bytes` as the artifact `(kind, name)`.  The bytes are
/// content-addressed: re-putting identical content reuses the
/// existing blob.  The write is committed by its manifest before
/// the index is updated, so an interrupted put is invisible and
/// recoverable.  Returns the committed record.
pub fn artifact_repository_put(
  repo : ArtifactRepository,
  kind : String,
  name : String,
  bytes : Array[Int32],
  format_version~ : Int32 = -1,
) -> ArtifactRecord? {
  if !artifact_name_ok(kind) || !artifact_name_ok(name) {
    return None
  }
  for i in 0..<bytes.length() {
    if bytes[i] < 0 || bytes[i] > 255 {
      return None
    }
  }
  let (hash_a, hash_b) = artifact_hash_pair(bytes)
  let base_digest = artifact_blob_digest(bytes)
  let mut suffix = 0
  let mut blob_key = ""
  let mut blob_found = false
  while !blob_found {
    if suffix > 1024 {
      return None
    }
    let digest = if suffix == 0 {
      base_digest
    } else {
      base_digest + "-x" + suffix.to_string()
    }
    let candidate = artifact_blob_key(repo, digest)
    match (repo.store.read)(candidate + ".commit") {
      Some(manifest) =>
        match artifact_manifest_parse(manifest) {
          Some(existing) =>
            if artifact_record_matches_bytes(existing, bytes) {
              blob_key = candidate
              blob_found = true
            } else {
              suffix = suffix + 1
            }
          None => suffix = suffix + 1
        }
      None => {
        blob_key = candidate
        blob_found = true
      }
    }
  }
  let record = ArtifactRecord::{
    kind,
    name,
    blob_key,
    byte_length: bytes.length(),
    hash_a,
    hash_b,
    format_version,
  }
  match (repo.store.read)(blob_key) {
    Some(existing) =>
      if existing != bytes {
        if !artifact_store_write_verified(repo.store, blob_key, bytes) {
          return None
        }
      }
    None =>
      if !artifact_store_write_verified(repo.store, blob_key, bytes) {
        return None
      }
  }
  if !artifact_store_write_verified(
      repo.store,
      blob_key + ".commit",
      artifact_manifest_bytes(record),
    ) {
    return None
  }
  let records = match artifact_repository_load_index(repo) {
    Some(v) => v
    None => return None
  }
  let kept : Array[ArtifactRecord] = []
  for i in 0..<records.length() {
    if !(records[i].kind == kind && records[i].name == name) {
      kept.push(records[i])
    }
  }
  kept.push(record)
  if !artifact_repository_save_index(repo, kept) {
    return None
  }
  repo.puts = repo.puts + 1
  Some(record)
}

///|
/// Fetch and fully verify an artifact: the commit manifest must
/// agree with the index, and the blob must match the recorded
/// length and both checksums.
pub fn artifact_repository_get(
  repo : ArtifactRepository,
  kind : String,
  name : String,
) -> Array[Int32]? {
  let records = match artifact_repository_load_index(repo) {
    Some(v) => v
    None => return None
  }
  let record = match artifact_records_find(records, kind, name) {
    Some(v) => v
    None => return None
  }
  let manifest = match (repo.store.read)(record.blob_key + ".commit") {
    Some(bytes) =>
      match artifact_manifest_parse(bytes) {
        Some(v) => v
        None => return None
      }
    None => return None
  }
  if manifest.blob_key != record.blob_key ||
    manifest.byte_length != record.byte_length ||
    manifest.hash_a != record.hash_a ||
    manifest.hash_b != record.hash_b {
    return None
  }
  let bytes = match (repo.store.read)(record.blob_key) {
    Some(v) => v
    None => return None
  }
  if !artifact_record_matches_bytes(record, bytes) {
    return None
  }
  Some(bytes)
}

///|
pub fn artifact_repository_record(
  repo : ArtifactRepository,
  kind : String,
  name : String,
) -> ArtifactRecord? {
  match artifact_repository_load_index(repo) {
    Some(records) => artifact_records_find(records, kind, name)
    None => None
  }
}

///|
pub fn artifact_repository_list(
  repo : ArtifactRepository,
) -> Array[ArtifactRecord] {
  match artifact_repository_load_index(repo) {
    Some(records) => records
    None => []
  }
}

///|
/// Remove an artifact from the index; its blob and manifest are
/// deleted when no remaining record references the same blob.
pub fn artifact_repository_remove(
  repo : ArtifactRepository,
  kind : String,
  name : String,
) -> Bool {
  let records = match artifact_repository_load_index(repo) {
    Some(v) => v
    None => return false
  }
  let record = match artifact_records_find(records, kind, name) {
    Some(v) => v
    None => return false
  }
  let kept : Array[ArtifactRecord] = []
  for i in 0..<records.length() {
    if !(records[i].kind == kind && records[i].name == name) {
      kept.push(records[i])
    }
  }
  if !artifact_repository_save_index(repo, kept) {
    return false
  }
  let mut referenced = false
  for i in 0..<kept.length() {
    if kept[i].blob_key == record.blob_key {
      referenced = true
    }
  }
  if !referenced {
    ignore((repo.store.remove)(record.blob_key))
    ignore((repo.store.remove)(record.blob_key + ".commit"))
  }
  true
}

///|
/// Rebuild the index from the commit manifests present in the
/// store, keeping only manifests whose blobs verify.  This is
/// the corruption-recovery path for a lost or damaged index.
/// Returns the number of recovered records, or -1 when the
/// rebuilt index could not be saved.
pub fn artifact_repository_recover(repo : ArtifactRepository) -> Int32 {
  let blob_prefix = repo.prefix + "/blobs/"
  let keys = (repo.store.list)()
  let records : Array[ArtifactRecord] = []
  for i in 0..<keys.length() {
    let key = keys[i]
    if key.has_prefix(blob_prefix) && key.has_suffix(".commit") {
      match (repo.store.read)(key) {
        Some(manifest_bytes) =>
          match artifact_manifest_parse(manifest_bytes) {
            Some(record) =>
              match (repo.store.read)(record.blob_key) {
                Some(bytes) =>
                  if artifact_record_matches_bytes(record, bytes) &&
                    artifact_records_find(records, record.kind, record.name) ==
                    None {
                    records.push(record)
                  }
                None => ()
              }
            None => ()
          }
        None => ()
      }
    }
  }
  // Deterministic order, independent of store enumeration.
  for i in 0..<records.length() {
    for j in (i + 1)..<records.length() {
      let a = records[i]
      let b = records[j]
      if b.kind + "/" + b.name < a.kind + "/" + a.name {
        records[i] = b
        records[j] = a
      }
    }
  }
  if !artifact_repository_save_index(repo, records) {
    return -1
  }
  repo.recoveries = repo.recoveries + 1
  records.length()
}

///|
/// Every indexed artifact reads back and verifies.
pub fn artifact_repository_verify_all(repo : ArtifactRepository) -> Bool {
  let records = artifact_repository_list(repo)
  for i in 0..<records.length() {
    if artifact_repository_get(repo, records[i].kind, records[i].name) == None {
      return false
    }
  }
  true
}

///|
pub fn artifact_repository_stats(
  repo : ArtifactRepository,
) -> ArtifactRepositoryStats {
  let records = artifact_repository_list(repo)
  let mut total = 0
  for i in 0..<records.length() {
    total = total + records[i].byte_length
  }
  ArtifactRepositoryStats::{
    records: records.length(),
    total_bytes: total,
    puts: repo.puts,
    recoveries: repo.recoveries,
  }
}

// ------------------------------------------------------------------
// Typed wrappers: compiled modules and registry snapshots
// ------------------------------------------------------------------

///|
pub fn artifact_kind_compiled_module() -> String {
  "compiled-module"
}

///|
pub fn artifact_kind_schema_registry() -> String {
  "schema-registry"
}

///|
/// Store a compiled module under its module path.  With a
/// non-empty `peer_versions`, the bytes are negotiated down to
/// the highest mutually supported layout that can express the
/// module; otherwise the current layout is used.
pub fn artifact_repository_put_compiled_module(
  repo : ArtifactRepository,
  compiled : CompiledModule,
  peer_versions~ : Array[Int32] = [],
) -> ArtifactRecord? {
  let bytes = if peer_versions.length() == 0 {
    compiled_module_to_binary(compiled)
  } else {
    match compiled_module_to_binary_for_peer(compiled, peer_versions) {
      Some(v) => v
      None => return None
    }
  }
  artifact_repository_put(
    repo,
    artifact_kind_compiled_module(),
    compiled.module_path,
    bytes,
    format_version=compiled_module_binary_version_of(bytes),
  )
}

///|
pub fn artifact_repository_get_compiled_module(
  repo : ArtifactRepository,
  module_path : String,
) -> CompiledModule? {
  let bytes = match
    artifact_repository_get(repo, artifact_kind_compiled_module(), module_path) {
    Some(v) => v
    None => return None
  }
  compiled_module_load_binary(bytes)
}

///|
pub fn artifact_repository_put_registry_snapshot(
  repo : ArtifactRepository,
  name : String,
  snapshot : DSchemaRegistrySnapshot,
  peer_versions~ : Array[Int32] = [],
) -> ArtifactRecord? {
  let bytes = if peer_versions.length() == 0 {
    schema_registry_snapshot_to_binary(snapshot)
  } else {
    match schema_registry_snapshot_to_binary_for_peer(snapshot, peer_versions) {
      Some(v) => v
      None => return None
    }
  }
  artifact_repository_put(
    repo,
    artifact_kind_schema_registry(),
    name,
    bytes,
    format_version=schema_registry_binary_version_of(bytes),
  )
}

///|
pub fn artifact_repository_get_registry_snapshot(
  repo : ArtifactRepository,
  name : String,
) -> DSchemaRegistrySnapshot? {
  let bytes = match
    artifact_repository_get(repo, artifact_kind_schema_registry(), name) {
    Some(v) => v
    None => return None
  }
  schema_registry_snapshot_from_binary(bytes)
}
