local oldclass = class

-- rapanui pultes the global scope with anoying functions as 'class'
import({'rapanui-sdk/rapanui'},'rapanui/','rapanui-sdk')

class = oldclass