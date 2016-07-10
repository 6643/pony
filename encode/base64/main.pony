use bb = "encode/base64"

actor Main
  new create(env: Env) =>

    try
      let base64 = Base64()
      env.out.print(base64.encode("111济公：第8集"))
      env.out.print(base64.decode("MTEx5rWO5YWs77ya56ysOOmbhg=="))

      var str ="6K+36L6T5YWl6KaB6L+b6KGM57yW56CB5oiW6Kej56CB55qE5a2X56ym77yaCuivt+i+k+WFpeimgei/m+ihjOe8lueggeaIluino+eggeeahOWtl+espu+8mgror7fovpPlhaXopoHov5vooYznvJbnoIHmiJbop6PnoIHnmoTlrZfnrKbvvJo="
      
      env.out.print(base64.decode(str))

    else
      env.out.print("deode error")
    end

