
let g:loaded_pkgsync = 1

let s:CMDFORMAT_CLONE = 'git -c credential.helper= clone --no-tags --single-branch --depth 1 https://github.com/%s/%s.git'
let s:CMDFORMAT_PULL  = 'git -c credential.helper= pull'

let s:KIND_UPDATING = 0
let s:KIND_INSTALLING = 1
let s:KIND_DELETING = 2
let s:KIND_ERROR = 3
let s:KIND_NORMAL = 4

command! -nargs=* -bang PkgSync :call <SID>pkgsync((<q-bang> == '!'), <f-args>)

let s:rootdir = expand('<sfile>:h:h')

function! s:pkgsync(bang, ...) abort
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
		else
			call pkgsync#update(args)
			if a:bang
				call pkgsync#clean(args)
			endif
		endif
	finally
		let &more = m
	endtry
endfunction

