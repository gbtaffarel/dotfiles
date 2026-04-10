config.load_autoconfig(False)

config.set("colors.webpage.darkmode.enabled", True)

# # Search engines
# c.url.searchengines = {
#     'DEFAULT':  'https://google.com/search?q={}',
#     'g':        'https://gemini.google.com/app', # Atalho rápido para o Gemini
#     'yt':       'https://www.youtube.com/results?search_query={}',
#     'aw':       'https://wiki.archlinux.org/index.php?search={}',
#     'cpp':      'https://en.cppreference.com/mwiki/index.php?search={}',
#     'gh':       'https://github.com/search?q={}',
# }

# c.url.auto_search = 'naive'

# Binds
config.bind(",yt", "open -t https://youtube.com")
config.bind(",ge", "open -t https://gemini.google.com")
config.bind(",md", "open -t https://moodle.ufrgs.br")

# set dark mode
# config.set("colors.webpage.darkmode.enabled", True)

# Set nvim as editor
config.set(
    "editor.command",
    ["kitty", "-e", "nvim", "{file}", "-c", "normal {line}G{column0}l"],
)
