module ApplicationHelper
	def command_label icon, label
		"<i class='#{icon} icon-white'></i> <span class='command-label'>&nbsp;#{label}</span>".html_safe
	end
end
