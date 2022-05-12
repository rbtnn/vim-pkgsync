
function! pkgsync#subcmds#list#exec(args) abort
	let j = pkgsync#common#read_config()
	call pkgsync#output('[packpath]')
	call pkgsync#output('  ' .. j['packpath'])
	let start_or_opts = filter(['start', 'opt'], { _,x -> 0 < len(keys(get(j['plugins'], x, {}))) })
	for start_or_opt in start_or_opts
		call pkgsync#output(' ')
		call pkgsync#output('[' .. start_or_opt .. ']')
		for user_name in sort(keys(j['plugins'][start_or_opt]))
			for plugin_name in sort(j['plugins'][start_or_opt][user_name])
				let dotgit_path = expand(printf('%s/pack/%s/%s/%s/.git', j['packpath'], user_name, start_or_opt, plugin_name))
				let prefix = ' '
				let branch_name = ''
				if filereadable(dotgit_path) || isdirectory(dotgit_path)
					let branch_name = '(' .. matchstr(get(readfile(expand(dotgit_path .. '/HEAD'), 1), 0, ''), '/\i\+/\zs\i\+') .. ')'
				else
					let prefix = '-'
				endif
				call pkgsync#output(printf('  %s%s/%s %s', prefix, user_name, plugin_name, branch_name))
			endfor
		endfor
	endfor
endfunction

