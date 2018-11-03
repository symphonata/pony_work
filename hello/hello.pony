actor Main
  new create(env: Env) =>
	  env.out.print("Hello, world!")
		var s = String
		s.append("hahahah")
		var s1 = s
		env.out.print(s1.string())

