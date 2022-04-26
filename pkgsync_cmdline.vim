
let s:rootdir = expand('<sfile>:h')

function s:main() abort
	try
		let g:pkgsync_stdout = 1
		execute printf('set runtimepath^=%s', escape(s:rootdir, ' '))
		call pkgsync#parse_cmdline(v:argv[5:])
		qall!
	catch
		put=v:exception
		print
		cquit!
	endtry
endfunction

call s:main()

