"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Stack Update
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Stack --->  Register
"
" Update register by setting an item from a stack.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:update_register(...) dict
    "{{{1
    if !self.size()
        return
    endif
    let ix = a:0 ? a:1 : self.offset
    let item = self.get(ix)
    call s:F.set_register(s:F.default_reg(), item.text, item.type)
endfunction "}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Register --->  Stack
"
" Update stack by adding an item from a register.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:update_stack(...) dict
    "{{{1
    let r = s:F.get_register(a:0 ? a:1 : '"')
    let text = r[1]
    let type = r[2]

    " text must contain printable characters
    if text =~ (self is s:Auto ? '[[:graph:]]' : '[[:print:]]')
        let item = {'text': text, 'type': type, 'ft': &ft}
        " if entry is duplicate, put it upfront removing the previous one
        let ix = index(self.stack, item)
        if ix >= 0
            call remove(self.stack, ix)
        endif
        call insert(self.stack, item)
    endif
    " if auto-stack size exceeds limit, remove entries from the tail
    if self is s:Auto
        while self.size() > get(g:, 'yanktools_auto_stack_size', 10)
            unlet self.stack[-1]
        endwhile
    endif
endfunction "}}}



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Stack methods
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""
" Clear the stack items.
""
function! s:clear_stack() dict
    "{{{1
    let self.stack = []
endfunction "}}}

""
" Set stack offset.
" Take overflow into account if going out of bounds.
" Returns: 0 if there was no overflow
"          1 if overflow was on the upper bound
"          2 if overflow was on the lower bound
""
function! s:move_offset(count) dict
    "{{{1
    let start = self.offset
    let max = self.size()
    let n = ( abs(a:count) % max ) * ( a:count > 0 ? 1 : -1 )
    let self.offset += n

    if self.offset >= max
        let self.offset = start + n - max
        return 1
    elseif self.offset < 0
        let self.offset = start + n + max
        return 2
    endif
    call self.update_register()
endfunction "}}}

""
" Get the numbers of items in the stack.
""
function! s:size() dict
    "{{{1
    return len(self.stack)
endfunction "}}}

""
" Return TRUE if the stack is empty.
""
function! s:is_empty() dict
    "{{{1
    if !self.size()
        call s:F.msg('Stack is empty')
        return 1
    endif
endfunction "}}}

""
" Set offset with bounds check, then update register.
""
function! s:set_at_offset(n) dict
    "{{{1
    let size = self.size()
    if !size | return | endif

    let self.offset = a:n >= size ? size - 1 :
                \           a:n < 0 ? 0 : a:n
    call self.update_register()
endfunction "}}}

""
" Verify that stack and register are synched, that is,
" the register content must match the current stack offset.
" If it's not, synch register and stack.
" Returns: FALSE if the stack was not synched.
""
function! s:synched() dict
    "{{{1
    if s:F.get_register()[1] != self.stack[self.offset].text
        call self.update_register()
        return v:false
    endif
    return v:true
endfunction "}}}

""
" Get stack item at current or N offset.
""
function! s:get(...) dict
    "{{{1
    return self.size() ? self.stack[a:0 ? a:1 : self.offset] : {}
endfunction "}}}




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize stacks
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Stack structures{{{1
let s:Yank  = {
            \ 'name': 'Yank', 'offset': 0,
            \ 'clear': function('s:clear_stack'),
            \ 'update_stack': function('s:update_stack'),
            \ 'move_offset': function('s:move_offset'),
            \ 'size': function('s:size'),
            \ 'update_register': function('s:update_register'),
            \ 'set_at_offset': function('s:set_at_offset'),
            \ 'is_empty': function('s:is_empty'),
            \ 'get': function('s:get'),
            \ 'synched': function('s:synched'),
            \}


let s:Auto  = {
            \ 'name': 'Auto', 'offset': 0,
            \ 'size': function('s:size'),
            \ 'is_empty': function('s:is_empty'),
            \ 'clear': function('s:clear_stack'),
            \ 'get': function('s:get'),
            \ 'update_stack': function('s:update_stack'),
            \ 'move_offset': function('s:move_offset'),
            \ 'update_register': function('s:update_register'),
            \ 'synched': function('s:synched'),
            \}


let s:Zeta  = {'name': 'Zeta', 'offset': 0,
            \ 'clear': function('s:clear_stack'),
            \ 'is_empty': function('s:is_empty'),
            \ 'size': function('s:size'),
            \ 'get': function('s:get'),
            \ 'update_register': function('s:update_register'),
            \}
"}}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Stack-specific methods
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""
" Duplicate yanks will be added to this stack.
""
function! s:Zeta.update_stack() dict
    "{{{1
    let r = s:F.get_register()
    call add(self.stack, {'text': r[1], 'type': r[2], 'ft': &ft})
    if s:v.restoring
        call s:F.restore_register()
    endif
endfunction "}}}

""
" Set register and remove index from stack
""
function! s:Zeta.pop_stack() abort
    "{{{1
    call self.update_register()
    call remove(self.stack, self.offset)
endfunction "}}}

""
" Transfer a yank from the auto stack to the regular stack.
""
function! s:Auto.transfer_yank(ix) abort
    "{{{1
    call self.update_register(a:ix)
    call s:Yank.update_stack()
    call remove(self.stack, a:ix)
endfunction "}}}





"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize variables
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:yanktools.yank = s:Yank
let g:yanktools.zeta = s:Zeta
let g:yanktools.auto = s:Auto

let s:v = g:yanktools.vars
let s:F = g:yanktools.Funcs

""
" Initialize stacks.
""
function! yt#stack#init()
    "{{{1
    call s:Yank.clear()
    call s:Zeta.clear()
    call s:Auto.clear()
endfunction "}}}

" vim: ft=vim et sw=4 ts=4 sts=4 fdm=marker
