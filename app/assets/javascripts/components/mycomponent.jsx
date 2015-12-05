var Element = function(props) {
  return <p>Hello {props.name}</p>;
}

window.el = <Element name="world"/>;