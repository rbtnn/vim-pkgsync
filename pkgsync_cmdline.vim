
let s:rootdir = expand('<sfile>:h')

function s:main() abort
	try
		let g:pkgsync_stdout = 1
		execute printf('source %s/autoload/pkgsync.vim', s:rootdir)
		let args = v:argv[4:]
		if 0 < len(args)
			if args[0] == 'init'
				call pkgsync#init(args)
			elseif args[0] == 'list'
				call pkgsync#list(args)
			elseif args[0] == 'install'
				call pkgsync#install(args)
			elseif args[0] == 'uninstall'
				call pkgsync#uninstall(args)
			elseif args[0] == 'update'
				call pkgsync#update(args)
			elseif args[0] == 'clean'
				call pkgsync#clean(args)
			endif
		endif
	catch
		put=v:exception
		print
	endtry
endfunction

call s:main()

