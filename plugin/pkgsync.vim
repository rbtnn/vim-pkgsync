
let g:loaded_pkgsync = 1

command! -complete=customlist,pkgsync#comp -nargs=* PkgSync :call <SID>pkgsync(<f-args>)

let s:rootdir = expand('<sfile>:h:h')

function! s:pkgsync(...) abort
	let m = &more
	try
		set nomore
		execute printf('source %s/autoload/pkgsync.vim', s:rootdir)
		let args = a:000
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
	finally
		let &more = m
	endtry
endfunction

