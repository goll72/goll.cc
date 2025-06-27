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

	const button : HTMLButtonElement = document.createElement("button");

	if (singleChoice) {
		button.textContent = "Verificar resposta";
	} else {
		button.textContent = "Verificar respostas";
	}

	button.addEventListener("click", () => {
		button.disabled = true;
		button.value = "Disabled";

		checkQuiz(quiz, singleChoice, correct);
	})

	quiz.appendChild(button);
}

function checkQuiz(quiz : HTMLElement, singleChoice : boolean, correct : boolean[]): void {
	const choices: HTMLCollectionOf<HTMLInputElement> = quiz.getElementsByTagName("input");

	for (let i = 0; i < choices.length; i++) {
		if (correct[i]) { // Opção é uma correta resposta
			if (singleChoice || choices[i].checked) {
				choices[i].parentElement!.style.color = "green";
			} else {
				choices[i].parentElement!.style.color = "red";
			}
		} else {
			if (choices[i].checked) {
				choices[i].parentElement!.style.color = "red";
			}
		}
	}
}
