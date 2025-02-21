import pdb

class Config(pdb.DefaultConfig):
    # Colors 
    use_terminal256formatter = False
    current_line_color = pdb.Color.yellow
    filename_color = pdb.Color.white
    line_number_color = pdb.Color.white

    # Miscellaneous
    editor = 'nvim'
    sticky_by_default = True
    pretty_print = True
    truncate_height = 60
    max_width = 80
    prompt = '(debugger) '
    
