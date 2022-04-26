
function! pkgsync#subcmds#install#exec(args) abort
	let j = pkgsync#common#read_config()
	let m = matchlist(join(a:args), '^install\s\+\(opt\s\+\)\?\([^/]\+\)/\([^/]\+\)$')
	if !empty(m)
		let start_or_opt = (m[1] =~# '^opt\s\+$') ? 'opt' : 'start'
		let user_name = m[2]
		let plugin_name = m[3]
		let d = {}
		let d[user_name] = [plugin_name]
		let params = pkgsync#common#make_params(expand(j['packpath']), (start_or_opt == 'start') ? d : {}, (start_or_opt == 'opt') ? d : {})
		call pkgsync#common#start_jobs(params)
		call pkgsync#common#wait_jobs(params)
		call pkgsync#common#helptags(params)
		let path = globpath(expand(j['packpath']), join(['pack', user_name, start_or_opt, plugin_name], '/'))
		if isdirectory(path)
			let j['plugins'][start_or_opt][user_name] = get(j['plugins'][start_or_opt], user_name, [])
			if -1 == index(j['plugins'][start_or_opt][user_name], plugin_name)
				let j['plugins'][start_or_opt][user_name] += [plugin_name]
			endif
			call pkgsync#common#write_config(j)
		endif
	else
		call pkgsync#error('Invalid arguments!')
	endif
endfunction

