local UIComponent = class()

function UIComponent:_init(initial_dict)
    self.dict = initial_dict or {}
end
