module main

import os
import net.http
import time

fn main() {
	mut stop_watch := time.new_stopwatch()
	stop_watch.start()
	
	mut log_file := get_log_file()
	mut names := get_word_list()
	for name in names {
		if make_request(name) {
			println('[!!!] FOUND NAME ${name}')
			log_file.write_string('[!!!] FOUND NAME ${name}\n')!
		} else {
			println('[x] ${name} was taken')
			log_file.write_string('[x] ${name} was taken\n')!
		}
	}

	log_file.close()

	stop_watch.stop()
	mut duration := stop_watch.elapsed()
	mut taken := duration.str()
	
	println('Took ${taken}')
}

fn get_word_list() []string {
	mut relative_path := os.args[1]
	mut absolute_path := os.abs_path(relative_path)
	
	os.open(absolute_path) or {
		println('failed to find file at ${absolute_path}')
		exit(1)
	}

	mut lines := os.read_lines(absolute_path) or {
		println('failed to read file at ${absolute_path}')
		exit(1)
	}

	return lines
}

fn get_log_file() os.File {
	mut relative_path := os.args[2]
	mut absolute_path := os.abs_path(relative_path)

	mut f := os.create(absolute_path) or {
		println('file was not writable.')
		exit(1)
	}

	return f
}

// true = free
// false = taken
fn make_request(name string) bool {
	mut resp := http.get('https://github.com/${name}') or {
		println('failed to make request to ${name}')
		exit(1)
	}

	if resp.status_code == 404 {
		return true
	}

	return false
}