const allQuizzes : NodeListOf<HTMLElement> = document.querySelectorAll(".quiz-question");

for(let quiz of allQuizzes) {
	const choices = quiz.getElementsByTagName("input");
	const singleChoice = quiz.classList.contains("single-choice");
	let name: string | null = null;

	if (singleChoice) {
		name = quiz.getAttribute("id");
	}

	const correct : boolean[] = [];
	
	for (const choice of choices) {
		correct.push(choice.checked);
			
		if(singleChoice) {
			choice.setAttribute("type", "radio");
			choice.setAttribute("name", name ?? "");
		}

		choice.checked = false;
	}

	const answerBlocks : NodeListOf<HTMLElement> = quiz.querySelectorAll(".explanation");
	for(let ansBlk of answerBlocks) {
		ansBlk.classList.add("hidden");
	}

	const button : HTMLButtonElement = document.createElement("button");

	if (singleChoice) {
		button.textContent = "Verificar resposta";
	} else{
		button.textContent = "Verificar respostas";
	}

	button.addEventListener("click", () => {
		button.disabled = true;
		checkQuiz(quiz, singleChoice, correct);
	})

	quiz.appendChild(button);
}


function checkQuiz(quiz : HTMLElement, singleChoice : boolean, correct : boolean[]): void {
	const choices: HTMLCollectionOf<HTMLLIElement> = quiz.getElementsByTagName("li");

	for(let i = 0; i < choices.length; i++) {
		// An answer will be marked green, in a single choice quiz,
		// if it is simply the correct one, or, in a multiple choice one,
		// if it is marked. It will be marked red if it was incorrect but was
		// selected. The ones that were not selected and also were not correct
		// will be left the original color.
		const input = choices[i].querySelector("input")!;

		input.disabled = true;

		if(correct[i] != input.checked) {
			if(singleChoice && correct[i]) {
				choices[i].classList.add("correct");
			}
			else {
				choices[i].classList.add("wrong");
			}

			choices[i].querySelector(".explanation")!.classList.remove("hidden");
		}
		else if(correct[i]) {
			choices[i].classList.add("correct");
		}
	}
}
