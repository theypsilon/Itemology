local Data; import();
return {
    atlass          = Data.atlass.Sprites,
    skip            = 6,
    default         = 'djump',
    mirror          = false,
    sequences = {
        djump  = {{'coin1', scolor={'FF0000',6}, skip = 60, once = 1},{'coin2', skip = 6},'coin3','coin4','coin5','coin6','coin7','coin8'}, 
        fjump  = {{'coin1', color='00FF00'},'coin2','coin3','coin4','coin5','coin6','coin7','coin8'},
        pjump  = {{'coin1', color='0000FF'},'coin2','coin3','coin4','coin5','coin6','coin7','coin8'},
        xjump  = {{'coin1', color='EDEDED'},'coin2','coin3','coin4','coin5','coin6','coin7','coin8'},
        tjump  = {{'coin1', color='ED00ED'},'coin2','coin3','coin4','coin5','coin6','coin7','coin8'},
        kjump  = {{'coin1', color='00EDFF'},'coin2','coin3','coin4','coin5','coin6','coin7','coin8'},
        sjump  = {{'coin1', color='FFD700'},'coin2','coin3','coin4','coin5','coin6','coin7','coin8'},
    },
}