import argv
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  case argv.load().arguments {
    [day_str] -> {
      case int.parse(day_str) {
        Ok(day) -> setup_day(day)
        Error(_) -> {
          io.println("Error: Day must be a number")
          io.println("Usage: gleam run -m setup_day -- <day_number>")
        }
      }
    }
    _ -> {
      io.println("Usage: gleam run -m setup_day -- <day_number>")
      io.println("Example: gleam run -m setup_day -- 1")
    }
  }
}

fn setup_day(day: Int) {
  let day_str = int.to_string(day) |> string.pad_start(2, "0")
  let day_name = "day" <> day_str

  io.println("Setting up " <> day_name <> "...")

  // Create inputs directory
  let inputs_dir = "inputs/" <> day_name
  case simplifile.is_directory(inputs_dir) {
    Ok(True) -> io.println("⊘ Already exists: " <> inputs_dir)
    _ ->
      case simplifile.create_directory_all(inputs_dir) {
        Ok(_) -> io.println("✓ Created directory: " <> inputs_dir)
        Error(_) -> io.println("✗ Failed to create directory: " <> inputs_dir)
      }
  }

  // Create input files
  let input_files = ["input1.txt", "input2.txt", "input3.txt"]
  list.each(input_files, fn(filename) {
    let filepath = inputs_dir <> "/" <> filename
    case simplifile.is_file(filepath) {
      Ok(True) -> io.println("⊘ Already exists: " <> filepath)
      _ ->
        case simplifile.write(filepath, "") {
          Ok(_) -> io.println("✓ Created file: " <> filepath)
          Error(_) -> io.println("✗ Failed to create file: " <> filepath)
        }
    }
  })

  // Create day solution file
  let day_file = "src/" <> day_name <> ".gleam"
  case simplifile.is_file(day_file) {
    Ok(True) -> io.println("⊘ Already exists: " <> day_file)
    _ -> {
      let template = generate_day_template(day_str)
      case simplifile.write(day_file, template) {
        Ok(_) -> io.println("✓ Created file: " <> day_file)
        Error(_) -> io.println("✗ Failed to create file: " <> day_file)
      }
    }
  }

  io.println("\nSetup complete! You can now:")
  io.println("  1. Add your puzzle inputs to " <> inputs_dir <> "/")
  io.println("  2. Implement solutions in " <> day_file)
  io.println("  3. Run with: gleam run -m " <> day_name)
}

fn generate_day_template(day_str: String) {
  let day_name = "day" <> day_str
  "
import gleam/io
import simplifile

pub fn main() {
  let part1 = solve1()
  io.println(\"\\nPart 1 solution:\")
  io.println(part1)

  let part2 = solve2()
  io.println(\"\\nPart 2 solution:\")
  io.println(part2)

  let part3 = solve3()
  io.println(\"\\nPart 3 solution:\")
  io.println(part3)
}

fn solve1()  {
  let assert Ok(_input) = read_input(\"input1.txt\")

  \"TODO\"
}

fn solve2()  {
  let assert Ok(_input) = read_input(\"input2.txt\")

  \"TODO\"
}

fn solve3()  {
  let assert Ok(_input) = read_input(\"input3.txt\")

  \"TODO\"
}

fn read_input(filename: String) -> Result(String, simplifile.FileError) {
  let filepath = \"inputs/" <> day_name <> "/\" <> filename
  simplifile.read(filepath)
}
"
}
