
function! pkgsync#subcmds#update#exec(args) abort
	let j = pkgsync#common#read_config()
	let params = pkgsync#common#make_params(expand(j['packpath']), j['plugins']['start'], j['plugins']['opt'])
	call pkgsync#common#start_jobs(params)
	call pkgsync#common#wait_jobs(params)
	call pkgsync#common#helptags(params)
endfunction

