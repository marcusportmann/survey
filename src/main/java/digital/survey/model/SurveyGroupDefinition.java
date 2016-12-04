/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package digital.survey.model;

//~--- non-JDK imports --------------------------------------------------------

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyGroupDefinition</code> class implements the Survey Group Definition entity, which
 * represents a definition of a group of entities, e.g. a team, that are associated with a survey
 * definition.
 *
 * @author Marcus Portmann
 */
@JsonPropertyOrder({ "id", "name", "description", "groupMemberDefinitions" })
public class SurveyGroupDefinition
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey group definition.
   */
  @JsonProperty
  private UUID id;

  /**
   * The name of the survey group definition.
   */
  @JsonProperty
  private String name;

  /**
   * The description for the survey group definition.
   */
  @JsonProperty
  private String description;

  /**
   * The survey group member definitions associated with the survey group definition.
   */
  @JsonProperty
  private List<SurveyGroupMemberDefinition> groupMemberDefinitions;

  /**
   * Constructs a new <code>SurveyDefinitionGroup</code>.
   */
  @SuppressWarnings("unused")
  SurveyGroupDefinition() {}

  /**
   * Constructs a new <code>SurveyDefinitionGroup</code>.
   *
   * @param id          the Universally Unique Identifier (UUID) used to uniquely identify the
   *                    survey group definition
   * @param name        the name of the survey group definition
   * @param description the description for the survey group definition
   */
  public SurveyGroupDefinition(UUID id, String name, String description)
  {
    this.id = id;
    this.name = name;
    this.description = description;
    this.groupMemberDefinitions = new ArrayList<>();
  }

  /**
   * Add the survey group member definition to the survey group definition.
   *
   * @param groupMemberDefinition the survey group member definition
   */
  public void addGroupMemberDefinition(SurveyGroupMemberDefinition groupMemberDefinition)
  {
    groupMemberDefinitions.add(groupMemberDefinition);
  }

  /**
   * Indicates whether some other object is "equal to" this one.
   *
   * @param obj the reference object with which to compare
   *
   * @return <code>true</code> if this object is the same as the obj argument otherwise
   *         <code>false</code>
   */
  @Override
  public boolean equals(Object obj)
  {
    if (this == obj)
    {
      return true;
    }

    if (obj == null)
    {
      return false;
    }

    if (getClass() != obj.getClass())
    {
      return false;
    }

    SurveyGroupDefinition other = (SurveyGroupDefinition) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the description for the survey group definition.
   *
   * @return the description for the survey group definition
   */
  public String getDescription()
  {
    return description;
  }

  /**
   * Retrieve the survey group member definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           group member definition
   *
   * @return the survey group member definition or <code>null</code> if the survey group member
   *         definition could not be found
   */
  public SurveyGroupMemberDefinition getGroupMemberDefinition(UUID id)
  {
    for (SurveyGroupMemberDefinition groupMemberDefinition : groupMemberDefinitions)
    {
      if (groupMemberDefinition.getId().equals(id))
      {
        return groupMemberDefinition;
      }
    }

    return null;
  }

  /**
   * Returns the survey group member definitions associated with the survey group definition.
   *
   * @return the survey group member definitions associated with the survey group definition
   */
  public List<SurveyGroupMemberDefinition> getGroupMemberDefinitions()
  {
    return groupMemberDefinitions;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * definition.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *         definition
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the name of the survey group definition.
   *
   * @return the name of the survey group definition
   */
  public String getName()
  {
    return name;
  }

  /**
   * Remove the survey group member definition from the survey group definition.
   *
   * @param id the Universally Unique Identifier (UUID) used  to uniquely identify the survey
   *           group member definition
   */
  public void removeGroupMemberDefinition(UUID id)
  {
    for (SurveyGroupMemberDefinition groupMemberDefinition : groupMemberDefinitions)
    {
      if (groupMemberDefinition.getId().equals(id))
      {
        groupMemberDefinitions.remove(groupMemberDefinition);

        return;
      }
    }
  }

  /**
   * Set the description for the survey group definition.
   *
   * @param description the description for the survey group definition
   */
  public void setDescription(String description)
  {
    this.description = description;
  }

  /**
   * Set the name of the survey group definition
   *
   * @param name the name of the survey group definition
   */
  public void setName(String name)
  {
    this.name = name;
  }

  /**
   * Returns the String representation of the survey group definition.
   *
   * @return the String representation of the survey group definition
   */
  @Override
  public String toString()
  {
    StringBuilder buffer = new StringBuilder();

    buffer.append("SurveyGroupDefinition {");
    buffer.append("id=\"").append(getId()).append("\", ");
    buffer.append("name=\"").append(getName()).append("\", ");
    buffer.append("description=\"").append(getDescription()).append("\", ");

    buffer.append("groupMemberDefinitions={");

    for (int i = 0; i < groupMemberDefinitions.size(); i++)
    {
      if (i > 0)
      {
        buffer.append(", ");
      }

      buffer.append(groupMemberDefinitions.get(i));
    }

    buffer.append("}");

    buffer.append("}");

    return buffer.toString();
  }
}
