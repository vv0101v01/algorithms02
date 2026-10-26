///|
/// Phase 11: byte-level persistence for schema registries.
///
/// A registry snapshot is pure data (inductive/HIT descriptors and
/// their recorded validity), so it serializes with the same total
/// binary codec as compiled modules.  Format (all integers
/// little-endian, one byte 0--255 per `Array[Int32]` element):
///
///   bytes  0..8   magic `CHREGBIN`
///          8..10  format version (u16) = 1
///         10..12  reserved, must be 0
///         12..16  payload length (i32)
///         16..20  DJB2-xor checksum of the payload
///         20..    payload: inductive count, then for each entry
///                 its `DInductiveSpec` and validity flag; then the
///                 HIT count and its `DHitSpec`/validity pairs.
///
/// Loading re-checks range, magic, version, length and checksum,
/// decodes through the total (non-panicking) readers, rejects
/// trailing bytes, and restores by recomputing elaboration plans
/// exactly like `schema_registry_restore`.

///|
pub fn schema_registry_binary_format_version() -> Int32 {
  1
}

///|
pub struct DSchemaRegistryBinaryLoad {
  status : ModuleBinaryStatus
  snapshot : DSchemaRegistrySnapshot?
}

///|
fn registry_binary_magic() -> Array[Int32] {
  [67, 72, 82, 69, 71, 66, 73, 78]
}

///|
fn bw_registry_snapshot_payload(
  w : ModuleBinWriter,
  snapshot : DSchemaRegistrySnapshot,
) -> Unit {
  bw_i32(w, snapshot.inductive_specs.length())
  for i in 0..<snapshot.inductive_specs.length() {
    bw_inductive_spec(w, snapshot.inductive_specs[i])
    bw_bool(
      w,
      if i < snapshot.inductive_valid.length() {
        snapshot.inductive_valid[i]
      } else {
        false
      },
    )
  }
  bw_i32(w, snapshot.hit_specs.length())
  for i in 0..<snapshot.hit_specs.length() {
    bw_hit_spec(w, snapshot.hit_specs[i])
    bw_bool(
      w,
      if i < snapshot.hit_valid.length() {
        snapshot.hit_valid[i]
      } else {
        false
      },
    )
  }
}

///|
pub fn schema_registry_snapshot_to_binary(
  snapshot : DSchemaRegistrySnapshot,
) -> Array[Int32] {
  let payload_writer = module_bin_writer_new()
  bw_registry_snapshot_payload(payload_writer, snapshot)
  let payload = payload_writer.bytes
  let writer = module_bin_writer_new()
  let magic = registry_binary_magic()
  for i in 0..<magic.length() {
    bw_u8(writer, magic[i])
  }
  bw_u8(writer, schema_registry_binary_format_version())
  bw_u8(writer, schema_registry_binary_format_version() >> 8)
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
pub fn schema_registry_to_binary(registry : DSchemaRegistry) -> Array[Int32] {
  schema_registry_snapshot_to_binary(schema_registry_snapshot(registry))
}

///|
fn registry_binary_failure(
  status : ModuleBinaryStatus,
) -> DSchemaRegistryBinaryLoad {
  { status, snapshot: None, }
}

///|
fn br_registry_snapshot_payload(
  r : ModuleBinReader,
) -> DSchemaRegistrySnapshot? {
  let inductive_specs : Array[DInductiveSpec] = []
  let inductive_valid : Array[Bool] = []
  let inductive_count = br_count(r)
  if !br_require_ok(r) {
    return None
  }
  for _ in 0..<inductive_count {
    match br_inductive_spec(r, 0) {
      Some(spec) => {
        inductive_specs.push(spec)
        inductive_valid.push(br_bool(r))
      }
      None => return None
    }
    if !br_require_ok(r) {
      return None
    }
  }
  let hit_specs : Array[DHitSpec] = []
  let hit_valid : Array[Bool] = []
  let hit_count = br_count(r)
  if !br_require_ok(r) {
    return None
  }
  for _ in 0..<hit_count {
    match br_hit_spec(r, 0) {
      Some(spec) => {
        hit_specs.push(spec)
        hit_valid.push(br_bool(r))
      }
      None => return None
    }
    if !br_require_ok(r) {
      return None
    }
  }
  Some({ inductive_specs, inductive_valid, hit_specs, hit_valid, })
}

///|
/// Parse registry bytes, reporting a precise format status.
pub fn schema_registry_snapshot_load_binary_report(
  bytes : Array[Int32],
) -> DSchemaRegistryBinaryLoad {
  for i in 0..<bytes.length() {
    if bytes[i] < 0 || bytes[i] > 255 {
      return registry_binary_failure(ModuleBinaryMalformed)
    }
  }
  if bytes.length() < 20 {
    return registry_binary_failure(ModuleBinaryTruncated)
  }
  let magic = registry_binary_magic()
  for i in 0..<magic.length() {
    if bytes[i] != magic[i] {
      return registry_binary_failure(ModuleBinaryBadMagic)
    }
  }
  if module_binary_u16_at(bytes, 8) != schema_registry_binary_format_version() ||
    module_binary_u16_at(bytes, 10) != 0 {
    return registry_binary_failure(ModuleBinaryUnsupportedVersion)
  }
  let payload_length = module_binary_i32_at(bytes, 12)
  if payload_length < 0 {
    return registry_binary_failure(ModuleBinaryMalformed)
  }
  if bytes.length() < 20 + payload_length {
    return registry_binary_failure(ModuleBinaryTruncated)
  }
  if bytes.length() > 20 + payload_length {
    return registry_binary_failure(ModuleBinaryTrailingBytes)
  }
  let payload : Array[Int32] = []
  for i in 20..<bytes.length() {
    payload.push(bytes[i])
  }
  if module_binary_checksum(payload) != module_binary_i32_at(bytes, 16) {
    return registry_binary_failure(ModuleBinaryChecksumMismatch)
  }
  let reader = module_bin_reader_new(payload)
  let snapshot = match br_registry_snapshot_payload(reader) {
    Some(value) => value
    None => return registry_binary_failure(reader.status)
  }
  if reader.pos != payload.length() {
    return registry_binary_failure(ModuleBinaryTrailingBytes)
  }
  { status: ModuleBinaryOk, snapshot: Some(snapshot), }
}

///|
pub fn schema_registry_snapshot_from_binary(
  bytes : Array[Int32],
) -> DSchemaRegistrySnapshot? {
  schema_registry_snapshot_load_binary_report(bytes).snapshot
}

///|
/// Load bytes and restore a fresh registry (plans recomputed).
pub fn schema_registry_from_binary(bytes : Array[Int32]) -> DSchemaRegistry? {
  match schema_registry_snapshot_from_binary(bytes) {
    Some(snapshot) => Some(schema_registry_restore(snapshot))
    None => None
  }
}

///|
pub fn schema_registry_binary_to_hex(bytes : Array[Int32]) -> String {
  compiled_module_binary_to_hex(bytes)
}

///|
pub fn schema_registry_binary_from_hex(text : String) -> Array[Int32]? {
  compiled_module_binary_from_hex(text)
}

///|
/// Round-trip self-check: a registry survives serialization to
/// bytes (and back through hexadecimal text) with an identical
/// manifest.
pub fn schema_registry_binary_roundtrip_ok(registry : DSchemaRegistry) -> Bool {
  let bytes = schema_registry_to_binary(registry)
  let direct = match schema_registry_from_binary(bytes) {
    Some(restored) =>
      schema_registry_manifest(restored) == schema_registry_manifest(registry)
    None => false
  }
  if !direct {
    return false
  }
  let hex = schema_registry_binary_to_hex(bytes)
  match schema_registry_binary_from_hex(hex) {
    Some(back) => {
      if back.length() != bytes.length() {
        return false
      }
      for i in 0..<bytes.length() {
        if back[i] != bytes[i] {
          return false
        }
      }
      true
    }
    None => false
  }
}
