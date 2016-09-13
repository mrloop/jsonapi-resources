require File.expand_path('../../../test_helper', __FILE__)
require 'jsonapi-resources'

class IncludeDirectivesTest < ActiveSupport::TestCase

  def test_one_level_one_include
    directives = JSONAPI::IncludeDirectives.new(PersonResource, ['posts']).include_directives

    assert_hash_equals(
      {
        include_related: {
          posts: {
            include: true,
            include_related:{},
            include_in_join: true
          }
        }
      },
      directives)
  end

  def test_one_level_multiple_includes
    directives = JSONAPI::IncludeDirectives.new(PersonResource, ['posts', 'comments', 'tags']).include_directives

    assert_hash_equals(
      {
        include_related: {
          posts: {
            include: true,
            include_related:{},
            include_in_join: true
          },
          comments: {
            include: true,
            include_related:{},
            include_in_join: true
          },
          tags: {
            include: true,
            include_related:{},
            include_in_join: true
          }
        }
      },
      directives)
  end

  def test_two_levels_include_full_path
    directives = JSONAPI::IncludeDirectives.new(PersonResource, ['posts.comments']).include_directives

    assert_hash_equals(
      {
        include_related: {
          posts: {
            include: true,
            include_related:{
              comments: {
                include: true,
                include_related:{},
                include_in_join: true
              }
            },
            include_in_join: true
          }
        }
      },
      directives)
  end

  def test_no_eager_join
    directives = JSONAPI::IncludeDirectives.new(PersonResource, ['posts.tags']).include_directives

    assert_hash_equals(
      {
        include_related: {
          posts: {
            include: true,
            include_related:{
              tags: {
                include: true,
                include_related:{},
                include_in_join: false
              }
            },
            include_in_join: true
          }
        }
      },
      directives)
  end

  def test_two_levels_include_full_path_redundant
    directives = JSONAPI::IncludeDirectives.new(PersonResource, ['posts','posts.comments']).include_directives

    assert_hash_equals(
      {
        include_related: {
          posts: {
            include: true,
            include_related:{
              comments: {
                include: true,
                include_related:{},
                include_in_join: true
              }
            },
            include_in_join: true
          }
        }
      },
      directives)
  end

  def test_three_levels_include_full
    directives = JSONAPI::IncludeDirectives.new(PersonResource, ['posts.comments.tags']).include_directives

    assert_hash_equals(
      {
        include_related: {
          posts: {
            include: true,
            include_related:{
              comments: {
                include: true,
                include_related:{
                  tags: {
                    include: true,
                    include_related:{},
                    include_in_join: true
                  }
                },
                include_in_join: true
              }
            },
            include_in_join: true
          }
        }
      },
      directives)
  end

  def test_three_levels_include_full_model_includes
    directives = JSONAPI::IncludeDirectives.new(PersonResource, ['posts.comments.tags'])
    assert_array_equals([{:posts=>[{:comments=>[:tags]}]}], directives.model_includes)
  end

  def test_circular_adds_volatile_flag
    directives = JSONAPI::IncludeDirectives.new(Api::BoxResource, ['things', 'things.user','things.things']).include_directives

    assert_hash_equals(
        {
            include_related: {
                things: {
                    include: true,
                    include_related: {
                        user: {
                            include: true,
                            include_related: {},
                            include_in_join: true
                        },
                        things: {
                            include: true,
                            include_related: {},
                            include_in_join: true,
                            volatile: true
                        }
                    },
                    include_in_join: true,
                    volatile: true
                }
            }
        },
        directives)
  end

  def test_two_levels_include_primary_type
    directives = JSONAPI::IncludeDirectives.new(PostResource, ['author.posts']).include_directives

    assert_hash_equals(
        {
            include_related: {
                author: {
                    include: true,
                    include_related:{
                        posts: {
                            include: true,
                            include_related:{},
                            include_in_join: true,
                            volatile: true
                        }
                    },
                    include_in_join: true
                }
            }
        },
        directives)
  end
end
