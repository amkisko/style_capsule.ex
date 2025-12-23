# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 120,
  locals_without_parens: [
    # StyleCapsule.Component
    capsule: 1,
    # StyleCapsule.Phoenix
    register_inline: 2,
    register_inline: 3,
    register_stylesheet: 1,
    register_stylesheet: 2,
    render_styles: 1
  ]
]
