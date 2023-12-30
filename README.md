

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
      <ul>
        <li><a href="#Simulation/IDE-used">Simulation/IDE used</a></li>
      </ul>
      <ul>
        <li><a href="#Features-Supported">Features Supported</a></li>
      </ul>
    </li>
    <li>
	<a href="#contributing">Contributing</a>
      <ul>
        <li><a href="#For-Collaborators">For Collaborators</a>
	      <ul>
        	<li><a href="#initializing-first-time-only">Initializing</a></li>
       		<li><a href="#Pushing-into-Fork">Pushing into Fork</a></li>
     	      </ul>
	</li>
        <li><a href="#Owner-Contribution">Owner Contribution</a>
		<ul>
        	   <li><a href="#To-merge-branches">To merge branches</a></li>
       		   <li><a href="#To-Push">To Push</a></li>
     	        </ul>
	</li>
      </ul>
   </li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project
* The Programmable Interrupt Controller (PIC) is a pivotal component in computer systems, orchestrating the flow of interrupt requests between peripherals and the CPU. In the realm of hardware design, this project endeavors to create a Verilog-based implementation of a PIC, closely modeled after the venerable 8259 architecture. The 8259 PIC has long served as a linchpin in computing systems, facilitating efficient communication and interrupt management.


<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With


* [![Verilog][VerilogIcon]][Verilog-url]


<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Simulation/IDE used

* [![ModelSim][ModelSimIcon]][ModelSim-url] 
* [![VScode][VScodeIcon]][VScode-url]
<!-- CONTRIBUTING -->


### Features Supported
* 8086 Mode
* Fully nested mode
* Automatic End of Interrupt
* Automatic Rotation mode
* Cascade mode
* End of interrupt
* Specific End of interrupt
* Read status of PIC
* Edge/Level Trigger for Requests


<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contributing

## For Collaborators

### Initializing (First Time only!)

Please fork the repo and create a pull request.

1. Fork the Project 

2. Go to your file project on your PC and use git BASH :

	> $ git remote add upstream **OwnerRepoLink** 

	> $ git remote add origin **YourForkLink**

	> $ git fetch upstream 

	> $ git checkout master 

	> $ git merge upstream/master 


### Pushing into Fork

1. Pull files from upstream
	> $ git pull upstream master

2. add files to stages
	> $ git add . 

3. Commit your Changes
	> $ git commit -m 'Add some master'

4. Push to the Branch
	> $ git push origin master

5. Open a Pull Request



## Owner Contribution

### To merge branches

1. > $ git fetch origin <Branch>

2. > $ git merge origin/<Branch>

3. > $ git push origin master

### To Push

1. > $ git pull origin master

2. Do your changes

3. > $ git add .

4. > $ git commit -m "message"

5. > $ git push origin master


<p align="right">(<a href="#readme-top">back to top</a>)</p>





<!-- MARKDOWN LINKS & IMAGES -->

[contributors-shield]: https://img.shields.io/github/contributors/AndrewGemi/PIC_8259A.svg?style=for-the-badge
[contributors-url]: https://github.com/AndrewGemi/PIC_8259A/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/AndrewGemi/PIC_8259A.svg?style=for-the-badge
[forks-url]: https://github.com/AndrewGemi/PIC_8259A/network/members

[VerilogIcon]: https://img.shields.io/badge/Verilog-BoldTextHere?style=flat&logo=verilog&color=brightgreen
[Verilog-url]: https://www.verilog.com/ 
[ModelSim-url]: https://www.intel.com/content/www/us/en/software-kit/750368/modelsim-intel-fpgas-standard-edition-software-version-18-1.html
[ModelSimIcon]: https://img.shields.io/badge/Model-Sim-blue

[VScodeIcon]:https://img.shields.io/badge/VScode-blue

[VScode-url]:https://code.visualstudio.com/
