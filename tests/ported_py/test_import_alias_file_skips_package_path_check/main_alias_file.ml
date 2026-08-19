import "feature-codebehind/app.ml" as CodeBehind

function main(args)
  if CodeBehind.answer() != 42 then return 1 end if
  return 0
end function
