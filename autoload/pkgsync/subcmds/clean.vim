
function! pkgsync#subcmds#clean#exec(args) abort
	let j = pkgsync#common#read_config()
	call s:delete_unmanaged_plugins(expand(j['packpath']), j['plugins']['start'], j['plugins']['opt'])
endfunction



function! s:delete_unmanaged_plugins(pack_dir, start_d, opt_d) abort
	for d in [a:start_d, a:opt_d]
		let start_or_opt = (d == a:start_d ? 'start' : 'opt')
		for x in split(globpath(join([a:pack_dir, 'pack', '*', start_or_opt], '/'), '*'), "\n")
			let exists = v:false
			for user_name in keys(d)
				for plugin_name in d[user_name]
					if x =~# '[\/]' .. user_name .. '[\/]' .. start_or_opt .. '[\/]' .. plugin_name .. '$'
						let exists = v:true
						break
					endif
				endfor
			endfor
			if !exists
				call pkgsync#common#delete_carefull(a:pack_dir, x)
			endif
		endfor
		for x in split(globpath(join([a:pack_dir, 'pack', '*'], '/'), start_or_opt), "\n")
			if !len(readdir(x))
				call pkgsync#common#delete_carefull(a:pack_dir, x)
			endif
		endfor
	endfor
	for x in split(globpath(join([a:pack_dir, 'pack'], '/'), '*'), "\n")
		if !len(readdir(x))
			call pkgsync#common#delete_carefull(a:pack_dir, x)
		endif
	endfor
endfunction

