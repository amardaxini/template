run "rm -Rf  README public/index.html test app/views/layouts/*"
run "rm public/stylesheets/*"
gem "jquery-rails"
gem "devise", '>=1.1.2'
gem "will_paginate",'>=3.0.pre2' 
gem "paperclip"
run "bundle install"
FileUtils.cp_r(File.expand_path(File.join(File.dirname(__FILE__),"public","stylesheets"))+"/.","public/stylesheets/")
FileUtils.cp_r(File.expand_path(File.join(File.dirname(__FILE__),"public","images"))+"/.","public/images/")
FileUtils.cp_r(File.expand_path(File.join(File.dirname(__FILE__),"public","application_helper.rb")),"app/helpers/application_helper.rb")

generate("devise:install")
generate "jquery:install"
model_name = ask("What is your model name for authentcation?")
generate("devise #{model_name}")
generate("devise:views")
generate("controller #{model_name.pluralize}")
generate("controller home index")
#app_name = ask("What is your application name?")
app_name = File.expand_path(".").split("/").last
#Rails.root.basename.to_s
file "config/routes.rb", <<-END
#{app_name.camelize}::Application.routes.draw do
  devise_for :#{model_name.pluralize}
  resources :#{model_name.pluralize}
  root :to => "home#index"
end
END

  file "app/views/layouts/application.html.erb", <<-END
<!DOCTYPE html>
<html>
<head>
  <%= stylesheet_link_tag 'reset','grid','application'%>
  <%= javascript_include_tag :defaults %>
  <title><%= h(yield(:title) || "#{app_name.camelize}") %></title>
  <%= csrf_meta_tag %>
</head>
<body>
<div class="container_16 every-thing">
  <div id="fb-root"></div>
  <div class="header">
    <div class="grid_16">
     <div class="grid_8" >
         <div class="login-bar-left">Pms3</div>
     </div> 
      <div class="grid_8">
        <div id="login-bar-right">
        <ul>
          <% if !current_#{model_name}.blank? %>
          <li><%= link_to "Logout",  destroy_#{model_name}_session_path%></li>
              <li><%=link_to "Profile | ", edit_#{model_name}_registration_path %> </li>
              
          <% else %>
              <li><%= link_to "Register ", new_#{model_name}_registration_path %></li>
               <li><%= link_to "Login | ", new_#{model_name}_session_path %></li>
          <% end %>
        </ul>
        </div>
      </div>
     </div> 
   <%= clearing_span %>
    <div class="main-nav">
      <ul>
        <% if current_#{model_name}.blank? %>
            <li><%= link_to "Login", new_#{model_name}_session_path %></li>
            <li><%= link_to "Register ", new_#{model_name}_registration_path %></li>
        <% else %>
            <li><%= link_to "Home", root_url, :method => :delete %></li>
           <!--<li><%#= link_to "#{model_name}",#{model_name}_path(current_user) %></li>-->
        <% end %>

      </ul>
    </div>
  </div>
  <%= clearing_span %>
  <div id="wrapper">
    <div id="content" class="<%= main_content_css_class %>">
      <%= yield %>
    </div>
    <div class="<%=  sidebar_css_class %>">
      <%=yield :sidebar %>
    </div>

    <%= clearing_span %>
    <div class="push"></div>

    <%= clearing_span %>
  </div>

  <%= clearing_span %>
</div>
<%= clearing_span %>
<div  class="container_16">
  <div id="footer">
    <p class="copytight">&copy; 2010 <a href="http://raistech.com">Amar Daxini</a></p>
    <%= yield :javascripts %>

  </div>
</div>
</body>
</html>
END

file "config/initializers/setup_mail.rb", <<-END 
#ActionMailer::Base.smtp_settings = {
#  :address              => "smtp.gmail.com",
#  :port                 => 587,
#  :domain               => "",
#  :user_name            => "",
#  :password             => "",
#  :authentication       => "plain",
#  :enable_starttls_auto => true
#}
ActionMailer::Base.smtp_settings = {
  :address => "smtp.sendgrid.net",
  :port => 587,
  :domain => "",
  :authentication => :plain,
  :user_name => "",
  :password => "",
  :enable_starttls_auto => true
}
ActionMailer::Base.default_url_options[:host] = "localhost:3000"
END

