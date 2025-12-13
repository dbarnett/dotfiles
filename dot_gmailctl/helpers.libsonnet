{
  subjectHasAny(words):: { or: [{ subject: word } for word in words] },

  listIsAnyOf(lists):: {
    or: [
      { list: '<' + std.join('.', std.splitLimit(l, '@', 1)) + '>' }
      for l in lists
    ] + [
      { to: l }
      for l in lists
    ] + [
      { from: l }
      for l in lists
    ],
  },
}
