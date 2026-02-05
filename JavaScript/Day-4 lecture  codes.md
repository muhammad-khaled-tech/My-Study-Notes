```js
 var divs = document.getElementsByClassName("myClass");
 var divs2 = document.querySelectorAll(".myClass");
 var newEle = document.createElement("div");
newEle.setAttribute("class","myClass");
 newEle.textContent = "hello new";
document.body.append(newEle);
```
what is the difference between `var divs = document.getElementsByClassName("myClass");`  and `var divs2 = document.querySelectorAll(".myClass");` ? 
the main difference is that the method getElemntByClassName() returns an HTMLcollection that is dynamic with changes like if you added a new elelment after using the method like in line 3 , then the number of the elemnts in html collection changes and increase by one but the queryselectorall() method returns node list which is fixed in size 