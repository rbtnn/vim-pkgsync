
let s:rootdir = expand('<sfile>:h')

function s:main() abort
	try
		let g:pkgsync_stdout = 1
		execute printf('source %s/autoload/pkgsync.vim', s:rootdir)
		let args = v:argv[3:]
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
			else
				call pkgsync#error('unknown subcommand: ' .. string(args[0]))
			endif
		else
			call pkgsync#error('Please you must specify subcommand!')
		endif
		qall!
	catch
		put=v:exception
		print
		cquit!
	endtry
endfunction

call s:main()

