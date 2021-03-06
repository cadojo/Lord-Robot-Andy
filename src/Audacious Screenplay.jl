### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 81af4446-7384-11eb-2b09-4916d5e47ee0
begin
	
	using Dates 		# For timestamps
	using DotEnv 		# For loading the OpenAI API key
	using PyCall 		# For interacting with OpenAI's Python API
	using PlutoUI 		# For embedding the tweet above, and other fun visuals
	
end

# ╔═╡ 95ac84ac-7381-11eb-3087-6bdfce67861a
md"""
# Meet Lord Robot Andy!

🤖 💻 ✍️ 📔 🎭 🎫 😺

"""

# ╔═╡ 2e148102-7384-11eb-3683-63f615cfeaeb
html"""
<blockquote class="twitter-tweet"><p lang="en" dir="ltr">1. Did you see Cats in theaters? Have you been craving more content from Andrew Lloyd Webber? No? Just <a href="https://twitter.com/CaseyReiland?ref_src=twsrc%5Etfw">@CaseyReiland</a> and <a href="https://twitter.com/_natmiller?ref_src=twsrc%5Etfw">@_natmiller</a>? Luckily for them, more content is just a few lines of code away! Introducing: Lord (Robot) Andy! <a href="https://t.co/aMd6g6IXCA">https://t.co/aMd6g6IXCA</a></p>&mdash; Joe(y) Carpinelli (@code_lowered) <a href="https://twitter.com/code_lowered/status/1358630557161299972?ref_src=twsrc%5Etfw">February 8, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
"""

# ╔═╡ 78d4a6f6-7382-11eb-2568-ed3cae869fed
md"""
## Introduction
_An FAQ of sorts to introduce this project, and all it stands for._

#### Why, God why?
After watching Cats several times, two wonderful people asked for _even more_ Andrew Lloyd Webber content. Who are we to deny them?

#### How does Robot Andy work?

A stiff cup of coffee and some soft lofi music.

#### What software tools are used?
There are lots of free AI text generators out today, including Tensorflow and [textgenrnn](https://github.com/minimaxir/textgenrnn), and [OpenAI's](https://openai.com) GPT series. Some are used here — these tools are identified as they are used. See the end of this document for dependency setup and imports.


"""

# ╔═╡ 5a4acfc0-7390-11eb-0ebb-7b3fdde32b18
md"""
## Love Never (Ever) Dies
_A script written by Lord Andy themself._
"""

# ╔═╡ 7c649da6-7384-11eb-1c64-0dc21d83e13f
md"""
## Project Dependencies
_Let's load the Julia packages and other software tools that we need._
"""

# ╔═╡ 25f8a6b4-7385-11eb-0433-913d70041f71
md"""
#### Julia Packages
"""

# ╔═╡ 2d3c7bf8-7385-11eb-3eac-bb9a2642a75d
md"""
#### OpenAI API Setup
"""

# ╔═╡ e8eeb524-7384-11eb-06ba-2f24907cfc8d
begin
	
	# Top level of Git repository
	TOPLEVEL = string(read(`git rev-parse --show-toplevel`, String)[1:end-1])
	
	# Collect variables for .env file (not included in repo)
	DotEnv.config(path = joinpath(TOPLEVEL,".env"))
	ORG = ENV["ORG_ID"]
	KEY = ENV["API_KEY"]
	
	# Include OpenAI's Python API
	openai = pyimport("openai")
	openai.api_key = KEY
	
	# Create a logs directory (if needed)
	LOGSDIR = joinpath(TOPLEVEL, "logs")
	isdir(LOGSDIR) || mkdir(LOGSDIR)
	
end;

# ╔═╡ 0447062e-7386-11eb-0e1e-89c469497206
md"""
#### Helper Functions
"""

# ╔═╡ ec24f400-738a-11eb-1e56-ad0bbea7accf
md"""
###### Get a timestamp (yyyy-mm-dd-Thh-mm-ss-ms)
"""

# ╔═╡ 066fae54-738b-11eb-14b2-034e13166d6c
function timestamp(dt=now()) 
	
	return string(dt) |> 
			str->replace(str, ":"=>"-") |> 
			str->replace(str, "."=>"-") |>
			str->replace(str, "T"=>"-")
	
end;

# ╔═╡ 1aeba388-7386-11eb-1232-550d54e919ac
md"""
###### Give a Prompt, Get a Response
"""

# ╔═╡ 3153cec4-7391-11eb-03e4-a7c12786b9e6
md"""
###### Word Count
"""

# ╔═╡ 34aceb82-7391-11eb-20eb-63136247f19e
function wordcount(str)
	return length(split(str, " "))
end;

# ╔═╡ 819f260c-7388-11eb-3de0-a1a8694f7932
function GPT3(prompt::String; 
			  engine 		=	"davinci", 
			  max_tokens 	= 	wordcount(prompt), 
			  log 			= 	true,
	 		  filename 		=   joinpath(LOGSDIR, "GPT-3" * timestamp() * ".txt"),
		      temperature   =   0.9)
	
	response = openai.Completion.create(
		engine 		=	engine, 
		prompt 		=	prompt, 
		max_tokens 	= 	max_tokens,
		n 			= 	1,
		temperature =   0.9)
	
	response_text = string(first(response["choices"])["text"])
	if log
		open(filename, "w") do io
			write(io, 
				"""
				This file was autogenerated with GPT-3! All content 
				is checked for obscenities, and no prompts should 
				produce any inappropriate content. Still, if you
				find ANY offensive content in this file, please 
				contact the project's maintainer (@cadojo on GitHub).
				
				This file has the following format: <prompt>... <response>
				
				---
				
				$prompt...$response_text
			
				"""
			)
	   	end
	end
	
	return response_text
		
end;

# ╔═╡ 797c2706-7390-11eb-3c3d-d5ac477ff030
LNED = let
	
	LND = readlines(joinpath(TOPLEVEL, "scripts", "love-never-dies.txt"))
	LNED = Vector{String}()
	
	# Add opening line...
	push!(LNED, GPT3(first(LND)))
	
	# Find the ~next~ line which completes a sentence
	prompt_end = 2
	for line_id ∈ 2:length(LND)
		if any(map(ch->contains(LND[line_id], ch), (".","!","?")))
			prompt_end = line_id
			break
		end
	end
	
	# Collect the prompt
	prompt = reduce((x,y)->string(x,"\n",y), collect(LND[2:prompt_end]))
	
	# Generate a script!
	push!(LNED, prompt * GPT3(prompt * "\n\n"; max_tokens = 1800))
	
	LNED
	
end;

# ╔═╡ 8429e00e-7392-11eb-147c-879efb564798
with_terminal(print, string(LNED...))

# ╔═╡ Cell order:
# ╟─95ac84ac-7381-11eb-3087-6bdfce67861a
# ╟─2e148102-7384-11eb-3683-63f615cfeaeb
# ╟─78d4a6f6-7382-11eb-2568-ed3cae869fed
# ╟─5a4acfc0-7390-11eb-0ebb-7b3fdde32b18
# ╠═797c2706-7390-11eb-3c3d-d5ac477ff030
# ╠═8429e00e-7392-11eb-147c-879efb564798
# ╟─7c649da6-7384-11eb-1c64-0dc21d83e13f
# ╟─25f8a6b4-7385-11eb-0433-913d70041f71
# ╠═81af4446-7384-11eb-2b09-4916d5e47ee0
# ╟─2d3c7bf8-7385-11eb-3eac-bb9a2642a75d
# ╠═e8eeb524-7384-11eb-06ba-2f24907cfc8d
# ╟─0447062e-7386-11eb-0e1e-89c469497206
# ╟─ec24f400-738a-11eb-1e56-ad0bbea7accf
# ╠═066fae54-738b-11eb-14b2-034e13166d6c
# ╟─1aeba388-7386-11eb-1232-550d54e919ac
# ╠═819f260c-7388-11eb-3de0-a1a8694f7932
# ╟─3153cec4-7391-11eb-03e4-a7c12786b9e6
# ╠═34aceb82-7391-11eb-20eb-63136247f19e
