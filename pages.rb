module Pages

    def Pages.log(c)
        """
        <meta charset='UTF-8'>
        <title>TeXify Online</title>
        <h1>TeXify Error</h1>
        #{c}
        #{"<link rel='stylesheet' href='#{$options[:stylesheet]}' type='text/css' media='screen'>" if $options[:stylesheet]}
        #{"<script src='#{$options[:javascript]}' type='text/javascript' charset='utf-8'></script>" if $options[:javascript]}
        """
    end

    def Pages.error(c)
        """
        <meta charset='UTF-8'>
        <title>TeXify Online</title>
        <h1>TeXify Error</h1>
        <pre>#{c}</pre>
        #{"<link rel='stylesheet' href='#{$options[:stylesheet]}' type='text/css' media='screen'>" if $options[:stylesheet]}
        #{"<script src='#{$options[:javascript]}' type='text/javascript' charset='utf-8'></script>" if $options[:javascript]}
        """
    end

    def Pages.reject(c)
        """
        <meta charset='UTF-8'>
        <title>TeXify Online</title>
        <h1>TeXify Method Reject</h1>
        #{"<link rel='stylesheet' href='#{$options[:stylesheet]}' type='text/css' media='screen'>" if $options[:stylesheet]}
        #{"<script src='#{$options[:javascript]}' type='text/javascript' charset='utf-8'></script>" if $options[:javascript]}
        """
    end

    def Pages.mainpage
        """
        <meta charset='UTF-8'>
        <title>TeXify Online</title>
        <h1>TeXify Online</h1>
        Some Description here.
        <form method='post' enctype='multipart/form-data' action='#'>
            <input name='file' type='file'>
            <textarea name='opt' type='text'></textarea>
            <input type='submit' value='Submit'>
        </form>
        #{"<link rel='stylesheet' href='#{$options[:stylesheet]}' type='text/css' media='screen'>" if $options[:stylesheet]}
        #{"<script src='#{$options[:javascript]}' type='text/javascript' charset='utf-8'></script>" if $options[:javascript]}
        """
    end
end
