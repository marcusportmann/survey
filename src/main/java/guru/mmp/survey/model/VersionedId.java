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

package guru.mmp.survey.model;

//~--- JDK imports ------------------------------------------------------------

import javax.persistence.Column;
import java.io.Serializable;
import java.util.UUID;

/**
 * The <code>VersionedId</code> class implements the versioned ID class.
 *
 * @author Marcus Portmann
 */
public class VersionedId
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used, along with the version, to uniquely identify the
   * entity.
   */
  @Column(name = "ID", nullable = false)
  private UUID id;

  /**
   * The version of the entity
   */
  @Column(name = "VERSION", nullable = false)
  private int version;

  /**
   * Constructs a new <code>VersionedId</code>.
   *
   * Default constructor required for JPA.
   */
  @SuppressWarnings("unused")
  VersionedId() {}

  /**
   * Constructs a new <code>VersionedId</code>.
   *
   * @param id      the Universally Unique Identifier (UUID) used, along with the version, to
   *                uniquely identify the entity
   * @param version the version of the entity
   */
  public VersionedId(UUID id, int version)
  {
    this.id = id;
    this.version = version;
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

    VersionedId other = (VersionedId) obj;

    return ((id.equals(other.id)) && (version == other.version));
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used, along with the version, to uniquely
   * identify the entity.
   *
   * @return the Universally Unique Identifier (UUID) used, along with the version, to uniquely
   *         identify the entity
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the version of the entity.
   *
   * @return the version of the entity
   */
  public int getVersion()
  {
    return version;
  }

  /**
   * Returns a hash code value for the object.
   *
   * @return a hash code value for the object
   */
  @Override
  public int hashCode()
  {
    return ((id == null)
        ? 0
        : id.hashCode()) + version;
  }
}
