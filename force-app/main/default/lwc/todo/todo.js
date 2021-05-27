import { LightningElement, track } from "lwc";

export default class Todo extends LightningElement {
  @track
  todoTasks = [
    { id: 1, name: "Task 1" },
    { id: 2, name: "Task 2" },
    { id: 3, name: "Task 3" }
  ];
  newTask = "My new task";

  updateNewTask(event) {
    this.newTask = event.target.value;
    console.log(this.newTask);
  }

  addTaskToList() {
    this.todoTasks.push({ id: this.todoTasks.length + 1, name: this.newTask });
    this.newTask = "";
  }

  deleteTaskFromList(event) {
    const idToDelete = event.target.name;
    let todoTasks = this.todoTasks;
    const todoTaskIndex = todoTasks.findIndex((task) => task.id === idToDelete);

    todoTasks.splice(todoTaskIndex, 1);
  }
}
