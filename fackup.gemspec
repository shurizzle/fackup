Gem::Specification.new {|g|
    g.name          = 'fackup'
    g.version       = '0.0.1.2'
    g.author        = 'shura'
    g.email         = 'shura1991@gmail.com'
    g.homepage      = 'http://github.com/shurizzle/fackup'
    g.platform      = Gem::Platform::RUBY
    g.description   = 'Simple tool to do simple backups'
    g.summary       = g.description
    g.files         = Dir.glob('lib/**/*')
    g.require_path  = 'lib'
    g.executables   = [ 'fackup' ]
    g.has_rdoc      = true

    g.add_dependency('thor')
}
