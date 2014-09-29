-- http://pastebin.com/8XaZbQjL

function pastebin(url, fn)
    fs.delete(fn)
    return shell.run('pastebin', 'get', url, fn)
end

pastebin('ip0EYCYr', 'quarry')
pastebin('nEkRA28E', 'movement')
pastebin('safsqGeE', 'util')
pastebin('QHsmLBM9', 'structures')
pastebin('ct6xn7X1', 'strip')

-- vim: noet ts=2 sw=2
