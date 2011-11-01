Skyline concepts
================

To get a better understanding of Skyline here's a quick overview of the main building blocks.

Pages
-----

Skyline is primarily built around pages. Pages are ordered into a tree which represents the structure of the
website. Pages consist of two parts: static data and sections and they inherit their properties from articles.

Articles
--------

Article is a container class that adds the functionality needed to add sections, versioning, publication
and other cool stuff. Pages are articles too. You can subclass the `Article` class to create your
own custom editable object (A news item for instance)

Sections
--------

Sections are elements that are predefined and are used as building blocks for content. Skyline has a number of
sections built in but you can also add new sections.


Rendering
---------

Skyline articles are rendered by the show action of the Skyline::Site::PagesController this controller can be overwritten if
for instance you need to render a specific page template for an element that is not directly linked to a page.
Like articles.

Settings
--------

Settings can be used to link articles to pages but also to set defaults like templates or colors which
then can be used in the templates.