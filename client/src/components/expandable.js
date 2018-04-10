import React, { Component } from 'react';
import _ from 'lodash';

export default class Expandable extends Component {
  constructor(props) {
    super(props);
    this.state = {
      showAll: false
    }
    this.toggleShowAll = this.toggleShowAll.bind(this);
  }

  toggleShowAll(e){
    e.preventDefault();
    e.stopPropagation();
    this.setState({
      showAll: !this.state.showAll
    })
  }
  toggleText() {
    return this.state.showAll ? 'Aucun autre message' : 'Voir tous les messages'
  }

  isHidden(index) {
    if (index + 1 > this.props.show && !this.state.showAll) {
      return true
    }
  }

  render() {
    const items = this.props.items || [];
    let displays = [];

    _.forEach(items, (item, id, index) => {
      displays.push(this.props.children(item, this.isHidden(index)))
    });
    return (
      <ul className='list-unstyled'>
        {displays}
        <li>
          <p className="text-center">
            {<a href="#" onClick={this.toggleShowAll}>{this.toggleText()}</a>}
          </p>
        </li>
      </ul>
    )
  }
}