return function(settings: { ["use game:Http for request"]: boolean? })
	getgenv().setclipboard = setclipboard or toclipboard or function()
		error("Clipboard not supported")
	end
	getgenv().request = request
		or http_request
		or syn_request
		or function(request)
			if not settings["use game:Http for request"] then
				error("Request not supported")
			end
		end
end