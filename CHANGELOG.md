### 0.3.0
- Added `PageletRails::Controller` concern which allows to use pagelet functionality within existing rails controllers
- Added `pagelet_method` method which enables pagelet functionality for a single method
- `PageletRails::Concerns::Controller` renamed to `PageletRails::Component`

### 0.2.2
- Fix links with data-remote=true wrongly selected ([#18](https://github.com/antulik/pagelet_rails/pull/18))

### 0.2.1

- Add parameters to javascript `pagelet-loaded` event: id, tags, content

### 0.2.0

- Fixed bug when original html class is lost (#12)
- Simplified rendering, now it always renders outside div container
- New feature to trigger refresh of other pagelets on the page (`identified_by` and `trigger_change` methods)
- `redirect_to` inside pagelet does not affect the main page when redirect destination is also pagelet

### 0.1.8

- Fix executable "rails" conflicts with railties (#11)
- Added trial feature to trigger updates

### 0.1.7

- fixed Rails 5.1
- added compatibility with Rails 2.4

### 0.1.6

- fixed #3 include more data in pagelet request

### 0.1.5

- fixed #2 when routes were causing error 

### 0.1.4

- added support for server side includes rendering mode

### 0.1.3

- fixed #1 - ajax loading of single pagelet fails over https
- fixed templates
- fixed placeholder style

### 0.1.2

- removed 'slim' dependency
- rails 4 support

### 0.1.1

- fixed bugs with missing styles and dependencies
 
### 0.1.0

- extracted as a separate gem
