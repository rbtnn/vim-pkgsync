
let g:loaded_pkgsync = 1

command! -complete=customlist,pkgsync#comp -nargs=* PkgSync :call <SID>pkgsync(<f-args>)

let s:rootdir = expand('<sfile>:h:h')

function! s:pkgsync(...) abort
	let m = &more
	try
		set nomore
		execute printf('source %s/autoload/pkgsync.vim', s:rootdir)
		call pkgsync#parse_cmdline(a:000)
	catch
		echohl Error
		echo '[vim-pkgsync]' v:exception
		echo '[vim-pkgsync]' v:throwpoint
		echohl None
	finally
		let &more = m
	endtry
endfunction

