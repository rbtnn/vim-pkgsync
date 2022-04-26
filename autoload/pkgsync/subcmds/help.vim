
let s:root_dir = expand('<sfile>:h:h:h:h')

function! pkgsync#subcmds#help#exec(args) abort
	let readme_path = fnamemodify(s:root_dir .. '/README.md', ':p')
	if filereadable(readme_path)
		let lines = readfile(readme_path)
		let b = v:false
		for line in lines
			if line =~ '^### '
				let b = v:true
			endif
			if b
				if line =~ '^### '
					if get(g:, 'pkgsync_stdout', 0)
						call pkgsync#output(line[4:])
					else
						call pkgsync#output(substitute(line[4:], '\<vimpkgsync\>', ':PkgSync', ''))
					endif
				else
					call pkgsync#output('    ' .. line)
				endif
			endif
		endfor
	else
		call pkgsync#output('[help documents]')
	endif
endfunction

