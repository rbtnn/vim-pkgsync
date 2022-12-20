
function! pkgsync#subcmds#install#exec(args) abort
  let j = pkgsync#common#read_config()
  let m = matchlist(join(a:args), '^install\s\+\(opt\s\+\)\?\(branch=\S\+\s\+\)\?\([^/ ]\+\)/\([^/ ]\+\)$')
  if !empty(m)
    let start_or_opt = (m[1] =~# '^opt\s\+$') ? 'opt' : 'start'
    let branch_name = matchstr(trim(m[2]), '^branch=\zs.*$')
    let user_name = m[3]
    let plugin_name = m[4]
    let d = {}
    if empty(branch_name)
      let d[user_name] = [plugin_name]
    else
      let d[user_name] = [{ 'name': plugin_name, 'branch': branch_name, }]
    endif
    let params = pkgsync#common#make_params(expand(j['packpath']), (start_or_opt == 'start') ? d : {}, (start_or_opt == 'opt') ? d : {})
    call pkgsync#common#start_jobs(params)
    call pkgsync#common#wait_jobs(params)
    call pkgsync#common#helptags(params)
    let path = globpath(expand(j['packpath']), join(['pack', user_name, start_or_opt, plugin_name], '/'))
    if isdirectory(path)
      let j['plugins'][start_or_opt][user_name] = get(j['plugins'][start_or_opt], user_name, [])
      if -1 == pkgsync#common#find_pluginname(j['plugins'][start_or_opt][user_name], plugin_name)
        if empty(branch_name)
          let j['plugins'][start_or_opt][user_name] += [plugin_name]
        else
          let j['plugins'][start_or_opt][user_name] += [{ 'name': plugin_name, 'branch': branch_name }]
        endif
      endif
      call pkgsync#common#write_config(j)
    endif
  else
    call pkgsync#error('Invalid arguments!')
  endif
endfunction

