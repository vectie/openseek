///|
pub struct FileEntry {
  path : String
  content : String
}

///|
/// A small JSON-backed virtual filesystem for tests and eval fixtures.
///
/// The convention is a flat JSON object where each key is a slash-separated
/// relative file path and each value is that file's text content.
pub(all) struct FileSystem(Json)

///|
pub fn FileSystem::from_json(json : Json) -> FileSystem raise {
  let filesystem = FileSystem(json)
  filesystem.validate()
  filesystem
}

///|
pub fn FileSystem::from_pairs(
  files : Array[(String, String)],
) -> FileSystem raise {
  let object : Map[String, Json] = {}
  for file in files {
    let (path, content) = file
    validate_relative_path(path)
    if object.contains(path) {
      fail("duplicate file path: \{path}")
    }
    object[path] = Json::string(content)
  }
  FileSystem(Json::object(object))
}

///|
pub fn FileSystem::to_json(self : FileSystem) -> Json {
  let FileSystem(json) = self
  json
}

///|
pub fn FileSystem::validate(self : FileSystem) -> Unit raise {
  let _ = self.entries()
}

///|
pub fn FileSystem::entries(self : FileSystem) -> Array[FileEntry] raise {
  let FileSystem(json) = self
  guard json is Object(fields) else {
    fail("file system must be a JSON object")
  }
  let paths = fields.keys().collect()
  paths.sort()
  let entries : Array[FileEntry] = []
  for path in paths {
    validate_relative_path(path)
    match fields[path] {
      String(content) => entries.push({ path, content })
      _ => fail("file content for `\{path}` must be a string")
    }
  }
  entries
}

///|
pub fn FileSystem::paths(self : FileSystem) -> Array[String] raise {
  [
    for entry in self.entries() => entry.path
  ]
}

///|
pub fn FileSystem::get(self : FileSystem, path : String) -> String? raise {
  validate_relative_path(path)
  let FileSystem(json) = self
  guard json is Object(fields) else {
    fail("file system must be a JSON object")
  }
  match fields.get(path) {
    Some(String(content)) => Some(content)
    Some(_) => fail("file content for `\{path}` must be a string")
    None => None
  }
}

///|
pub async fn FileSystem::write_to(self : FileSystem, root : String) -> Unit {
  for entry in self.entries() {
    write_text(root, entry.path, entry.content)
  }
}

///|
pub async fn FileSystem::mismatch_on_disk(
  self : FileSystem,
  root : String,
) -> String {
  let entries = self.entries() catch {
    error => return "invalid file system: \{error}"
  }
  for entry in entries {
    let path = root + "/" + entry.path
    let content = @fs.read_file(path).text() catch {
      error => return "missing expected file \{entry.path}: \{error}"
    }
    if content != entry.content {
      return "content mismatch in \{entry.path}"
    }
  }
  ""
}

///|
pub async fn write_text(root : String, path : String, content : String) -> Unit {
  validate_relative_path(path)
  ensure_parent_dir(root, path)
  @fs.write_file(root + "/" + path, content, create_mode=CreateOrTruncate)
}

///|
fn validate_relative_path(path : String) -> Unit raise {
  if path == "" {
    fail("file path must not be empty")
  }
  if path.has_prefix("/") {
    fail("file path must be relative: \{path}")
  }
  if path.contains("\\") {
    fail("file path must use `/` separators: \{path}")
  }
  for part in path.split("/") {
    if part == "" {
      fail("file path must not contain empty components: \{path}")
    }
    if part == "." || part == ".." {
      fail("file path must not contain `.` or `..`: \{path}")
    }
  }
}

///|
async fn ensure_parent_dir(root : String, path : String) -> Unit {
  let parts = path.split("/").collect()
  if parts.length() <= 1 {
    return
  }
  let dirs : Array[StringView] = []
  for index in 0..<(parts.length() - 1) {
    dirs.push(parts[index])
  }
  let _ = @fs.mkdir(root + "/" + dirs.join("/"), recursive=true) catch {
    _ => ()
  }
}
