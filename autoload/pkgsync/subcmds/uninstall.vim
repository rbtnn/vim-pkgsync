
function! pkgsync#subcmds#uninstall#exec(args) abort
	let j = pkgsync#common#read_config()
	let m = matchlist(join(a:args), '^uninstall\s\+\(opt\s\+\)\?\([^/]\+\)/\([^/]\+\)$')
	if !empty(m)
		let start_or_opt = (m[1] =~# '^opt\s\+$') ? 'opt' : 'start'
		let user_name = m[2]
		let plugin_name = m[3]
		let j['plugins'][start_or_opt][user_name] = get(j['plugins'][start_or_opt], user_name, [])
		let i = index(j['plugins'][start_or_opt][user_name], plugin_name)
		if -1 != i
			call remove(j['plugins'][start_or_opt][user_name], i)
		endif
		if 0 == len(j['plugins'][start_or_opt][user_name])
			call remove(j['plugins'][start_or_opt], user_name)
		endif
		call pkgsync#common#write_config(j)
		let path = globpath(expand(j['packpath']), join(['pack', user_name, start_or_opt, plugin_name], '/'))
		call pkgsync#common#delete_carefull(expand(j['packpath']), path)
	else
		call pkgsync#error('Invalid arguments!')
	endif
endfunction

