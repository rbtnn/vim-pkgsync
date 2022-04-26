
function! pkgsync#subcmds#init#exec(args) abort
	if filereadable(pkgsync#common#get_config_path())
		call pkgsync#error('You are already initialized!')
	endif
	call pkgsync#common#write_config({
		\   'packpath': get(a:args, 1, '~/vim'),
		\   'plugins': {
		\     'start': {},
		\     'opt': {},
		\   },
		\ })
	call pkgsync#output('The initialization finished!')
endfunction

