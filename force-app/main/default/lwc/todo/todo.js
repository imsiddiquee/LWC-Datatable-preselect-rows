import { LightningElement, track, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getTasks from "@salesforce/apex/ToDoListController.getTasks";
import insertTask from "@salesforce/apex/ToDoListController.insertTask";
import deleteTask from "@salesforce/apex/ToDoListController.deleteTask";

export default class Todo extends LightningElement {
  @track
  todoTasks = [
    // { id: 1, name: "Task 1" },
    // { id: 2, name: "Task 2" },
    // { id: 3, name: "Task 3" }
  ];
  todoTasksResponse;
  newTask = "";

  @wire(getTasks) getTodoTask(response) {
    this.todoTasksResponse = response;
    let data = response.data;
    let error = response.error;
    if (data) {
      console.log("data");
      this.todoTasks = [];
      data.forEach((task) => {
        this.todoTasks.push({
          id: this.todoTasks.length + 1,
          name: task.Subject,
          recordId: task.Id
        });
      });
    } else if (error) {
      console.log("error");
    }
  }

  updateNewTask(event) {
    this.newTask = event.target.value;
    console.log(this.newTask);
  }

  addTaskToList() {
    // console.log("this.todoTasks:::", JSON.stringify(this.todoTasks));
    // this.todoTasks.push({ id: this.todoTasks.length + 1, name: this.newTask });
    // this.newTask = "";

    insertTask({ subject: this.newTask })
      .then((response) => {
        // this.accountRecords = response;

        this.todoTasks.push({
          id: this.todoTasks.length + 1,
          name: this.newTask,
          recordId: response.Id
        });
        this.newTask = "";
      })
      .catch((error) => {
        console.log(error.body.message);
      });
  }

  deleteTaskFromList(event) {
    const idToDelete = event.target.name;
    let todoTasks = this.todoTasks;
    let recordIdToDelete;
    const todoTaskIndex = todoTasks.findIndex((task) => task.id === idToDelete);

    recordIdToDelete = this.todoTasks[todoTaskIndex].recordId;
    deleteTask({ recordId: recordIdToDelete })
      .then((response) => {
        if (response) {
          todoTasks.splice(todoTaskIndex, 1);
        } else {
          console.log("Unable to delete task.");
        }
      })
      .catch((error) => {
        console.log(error);
      });
  }

  refreshTotoList() {
    refreshApex(this.todoTasksResponse);
  }
}
