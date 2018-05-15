using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using ExampleApp.Models;

namespace ExampleApp.Controllers
{
    public class HomeController : Controller
    {
        private IRepository _repository;
        private string _message;

        public HomeController(IRepository repository, IConfiguration config)
        {
            _repository = repository;
            _message = "Hello Mom!";
        }

        public IActionResult Index()
        {
            ViewBag.Message = _message;
            return View(_repository.Products);
        }
    }
}
