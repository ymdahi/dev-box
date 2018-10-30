### Mapping

The mapping works like this:

- Host: dev-box/public_html
- Guest: /var/www/html

By default, Apache is configured to server files from this directory. As such, any files or folders you place in this folder will be available at http://localhost:port/filename.extension

Check out http://localhost:port/info.php to see your server's php configuration.

If you want to install Drupal, WordPress, or you own application code to be served by this LAMP stack, you would place your codebase in here.

### Structure
You can create a folder structure like:

- public_html
    - index.html
    - project-1
    - project-2

And be able to access each folder as such:

- http://localhost:8081/index.html
- http://localhost:8081/project-1
- http://localhost:8081/project-2

_Note:_ in order to work with projects in folders you will have to make changes to the Apache virtual host configurations found at `/etc/apache2/sites-available`. Visit https://gitlab.com/snippets/1768581 for an Apache virtual host configuration template.