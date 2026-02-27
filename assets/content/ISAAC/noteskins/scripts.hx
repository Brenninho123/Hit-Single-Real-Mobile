
function dadSkin(){
    return 'noteSkins/noteskin';
}
function bfSkin(){
    return 'noteSkins/noteskin';
}

function quants(){
    return false;
}

function noteSplash(offsets)
{
    for(i in offsets){
        i.y += 50;
        i.x += 75;
    }
    return 'noteSplashes/noteskinplash';
}
function offset(noteOff, strumOff, susOff){
    
    var x = 50;
    var y = ClientPrefs.downScroll ? -15 : 15;
    for (i in strumOff) {i.x = x; i.y = y;}
    for (i in noteOff) {i.x = x; i.y = y;}
    for (i in susOff) {i.y = -y;}//gulp.
}