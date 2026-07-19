// exam: layout primitives for typesetting exams and matching answer keys
// from a shared question data set. Intended to be driven by a generator
// (see ../elisp/ox-exam.el) rather than written by hand, though every
// function below is plain, callable Typst.

#let question-counter = counter("exam-question")

/// Document template. Use as a show rule:
///
///   #show: exam-doc.with(
///     course-number: "MATH 101",
///     course-name: "Calculus I",
///     exam-name: "Midterm 1",
///     date: "2026-07-18",
///     version: "A",
///     key: false,
///   )
///
/// Everything after the show rule becomes `body`.
#let exam-doc(
  course-number: "",
  course-name: "",
  exam-name: "",
  date: "",
  version: none,
  key: false,
  body,
) = {
  set page(paper: "us-letter", margin: 1in)
  set text(font: "Libertinus Serif", size: 11pt)
  set par(justify: true)
  set enum(numbering: "1.")

  question-counter.update(0)

  grid(
    columns: (1fr, 1fr),
    align: (left + top, left + top),
    column-gutter: 1em,
    [
      *#course-number* --- #course-name \
      #exam-name#if version != none [ (Version #version)]#if key [ --- *Answer Key*] \
      #date
    ],
    if key [] else [
      #grid(
        columns: (auto, 1fr),
        column-gutter: 0.4em,
        align: (left + bottom, left + bottom),
        [Name:], line(length: 100%, stroke: 0.6pt),
      )
    ],
  )

  v(0.8em)

  body
}

/// A titled group of questions.
#let section(title, body) = {
  block(above: 1.2em, below: 0.6em, heading(level: 2, title))
  body
}

/// A multiple-choice question.
///
/// - question: question text (string or content)
/// - options: array of option text (string or content), in display order
/// - correct: index (0-based) of the correct option in `options`
/// - key: when true, marks the correct option
#let mcq(question, options, correct: none, key: false) = {
  question-counter.step()
  let letters = ("A", "B", "C", "D", "E", "F", "G", "H")
  block(above: 0.9em, below: 0.16em, breakable: false)[
    #context [*#question-counter.display().*] #question
    #for (i, opt) in options.enumerate() {
      let is-correct = key and correct == i
      block(inset: (left: 1.7em, top: 0.0em))[
        #if is-correct [
          *#letters.at(i)) #opt* #sym.checkmark
        ] else [
          #letters.at(i)) #opt
        ]
      ]
    }
  ]
}

/// A short-essay question.
///
/// - question: question text (string or content)
/// - space: blank writing space to leave in the exam (a length, e.g. 2in)
/// - answer: sample-answer text shown only when `key` is true
/// - key: when true, renders the sample answer instead of blank space
#let essay(question, space: 2in, answer: none, key: false) = {
  question-counter.step()
  block(above: 0.9em, below: 0.6em)[
    #context [*#question-counter.display().*] #question
    #if key [
      #block(
        above: 0.5em,
        inset: 0.6em,
        fill: rgb("#f2f2f2"),
        radius: 3pt,
        width: 100%,
      )[
        *Sample answer:* #if answer != none { answer } else [_(no answer key provided)_]
      ]
    ] else [
      #v(space)
    ]
  ]
}
