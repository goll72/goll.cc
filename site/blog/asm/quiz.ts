
const allQuizes : HTMLElement[] = document.querySelectorAll(".quiz-question");

for(let quiz of allQuizes){
	const choices : HTMLElement = quiz.getElementsByTagName("input");
	let singleChoice : boolean = false;
	let name : string;

	if(quiz.classList.contains("single-choice")){
		name = quiz.getAttribute("id");
		singleChoice = true;
	}

	const correct : boolean[] = [];
	for(let choice of choices){
		correct.push(choice.checked);
			
		if(singleChoice){
			choice.setAttribute("type", "radio");
			choice.setAttribute("name", name);
		}

		choice.checked = false;
	}

	let button : HTMLElement = document.createElement("button");

	if(singleChoice){
		button.textContent = "Verificar resposta";
	}
	else{
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
	const choices : HTMLElements[] = quiz.getElementsByTagName("input");

	for(let i = 0; i < choices.length; i++){

		if(correct[i]){ // Opção é uma correta resposta
			if(singleChoice || choices[i].checked){
				choices[i].parentElement.style.color = "green";
			}
			else{
				choices[i].parentElement.style.color = "red";
			}
		}

		else{ // Opção é uma correta resposta
			if(choices[i].checked){
				choices[i].parentElement.style.color = "red";
			}
		}
	}

}
